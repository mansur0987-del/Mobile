//
//  API.swift
//  advanced_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import Combine
import Foundation
import OpenMeteoSdk

enum NetworkError: Error {
	case unauthorised
	case timeout
	case serverError
	case invalidResponse(code_error: Int)
	case invalidUrl
}


class Network : ObservableObject {
	func Search(line : String) async throws -> [SearchData] {
		print("func Search city")
		guard let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=" + line)
		else { throw NetworkError.invalidUrl }
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = "GET"
		
		let (data, response) = try await URLSession.shared.data(for: urlRequest)
		guard (response as? HTTPURLResponse)?.statusCode == 200
		else { throw NetworkError.invalidResponse(code_error: (response as? HTTPURLResponse)?.statusCode ?? 500)}
		if let result_search = try? JSONDecoder().decode(ResultSearch.self, from: data){
			return result_search.results ?? []
		}
		throw NetworkError.serverError
	}
	
	func GetWeather(latitude : Double, longitude : Double, location : Location) async throws -> Location {
		print("func Get Weather")
		guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code,wind_speed_10m&hourly=temperature_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&format=flatbuffers")
		else { throw NetworkError.invalidUrl }
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = "GET"
		
		let responses = try await WeatherApiResponse.fetch(url: url)
		let response = responses[0]
		
		/// Attributes for timezone and location
		let utcOffsetSeconds = response.utcOffsetSeconds
		_ = response.timezone
		_ = response.timezoneAbbreviation

		let current = response.current!
		let hourly = response.hourly!
		let daily = response.daily!

		struct WeatherData {
		  let current: Current
		  let hourly: Hourly
		  let daily: Daily
		  
		  struct Current {
			let time: Date
			let temperature2m: Float
			let weatherCode: Float
			let wind_speed_10m: Float
		  }
		  struct Hourly {
			let time: [Date]
			let temperature2m: [Float]
			let weatherCode: [Float]
			let wind_speed_10m: [Float]
		  }
		  struct Daily {
			let time: [Date]
			let weatherCode: [Float]
			let temperature2mMax: [Float]
			let temperature2mMin: [Float]
		  }
		}

		/// Note: The order of weather variables in the URL query and the `at` indices below need to match!
		let data = WeatherData(
		  current: .init (
			time: Date(timeIntervalSince1970: TimeInterval(current.time + Int64(utcOffsetSeconds))),
			temperature2m: current.variables(at: 0)!.value,
			weatherCode: current.variables(at: 1)!.value,
			wind_speed_10m: current.variables(at: 2)!.value
		  ),
		  hourly: .init(
			time: hourly.getDateTime(offset: utcOffsetSeconds),
			temperature2m: hourly.variables(at: 0)!.values,
			weatherCode: hourly.variables(at: 1)!.values,
			wind_speed_10m: hourly.variables(at: 2)!.values
		  ),
		  daily: .init(
			time: daily.getDateTime(offset: utcOffsetSeconds),
			weatherCode: daily.variables(at: 0)!.values,
			temperature2mMax: daily.variables(at: 1)!.values,
			temperature2mMin: daily.variables(at: 2)!.values
		  )
		)

		/// Timezone `gmt` is deliberately used.
		/// By adding `utcOffsetSeconds` before, local-time is inferred
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = .gmt
		
		
		var location = LocationWaetherClean(location: location)
				
		location.current = CurrentWeather(
			temperature: data.current.temperature2m,
			wind_speed: data.current.wind_speed_10m,
			weather_code: weather_code_name.first(where: { WeatherCodeMan in
				WeatherCodeMan.code.contains(Int(data.current.weatherCode))
				})!)

		dateFormatter.dateFormat = "HH:mm"
		for (i, date) in data.hourly.time.enumerated().prefix(24) {
			let dateString = dateFormatter.string(from: date)
			location.daily.append(DailyWeather(
				id: i,
				time: dateFormatter.date(from: dateString)!,
				time_string: dateString,
				temperature: data.hourly.temperature2m[i],
				wind_speed: data.hourly.wind_speed_10m[i],
				weather_code: weather_code_name.first(where: { WeatherCodeMan in
					WeatherCodeMan.code.contains(Int(data.hourly.weatherCode[i]))
				})!
			))
		}

		dateFormatter.dateFormat = "yyyy-MM-dd"
		for (i, date) in data.daily.time.enumerated() {
			let dateString = dateFormatter.string(from: date)
			location.week.append(WeekWeather(
				id: i,
				date: dateFormatter.date(from: dateString)!,
				date_string: dateString,
				temperature_Max: data.daily.temperature2mMax[i],
				temperature_Min: data.daily.temperature2mMin[i],
				weather_code: weather_code_name.first(where: { WeatherCodeMan in
					WeatherCodeMan.code.contains(Int(data.daily.weatherCode[i]))
				})!
			))
		}
		return location
	}
}

func withTimeout<T>(
	seconds: Double,
	operation: @escaping () async throws -> T
) async throws -> T {
	try await withThrowingTaskGroup(of: T.self) { group in
		
		group.addTask {
			return try await operation()
		}

		group.addTask {
			try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
			throw TimeoutError()
		}

		let result = try await group.next()!
		group.cancelAll()
		return result
	}
}

struct TimeoutError: Error {}
