//
//  API.swift
//  medium_weather_app
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

var weather_code_name : [WeatherCodeMan] = [
	WeatherCodeMan(id: 0, name: "Clear sky", code: [0]),
	WeatherCodeMan(id: 1, name: "Partly cloudy", code: [1, 2, 3]),
	WeatherCodeMan(id: 2, name: "Fog", code: [45, 48]),
	WeatherCodeMan(id: 3, name: "Drizzle", code: [51, 53, 55, 61, 63, 65]),
	WeatherCodeMan(id: 4, name: "Rain", code: [66, 67, 80, 81, 82]),
	WeatherCodeMan(id: 5, name: "Snow", code: [71, 73, 75, 77, 85, 86]),
	WeatherCodeMan(id: 6, name: "Thunderstorm", code: [95, 96, 99]),
]

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
		
				
		print("Current")
		
		var location : Location = location
		location.current = CurrentWeather(
			temperature: data.current.temperature2m,
			wind_speed: data.current.wind_speed_10m,
			weather_code: weather_code_name.first(where: { WeatherCodeMan in
				WeatherCodeMan.code.contains(Int(data.current.weatherCode))
				})!)

		print(data.current.temperature2m.formatted(.number.precision(.fractionLength(1))), "°C")
		print(weather_code_name.first(where: { WeatherCodeMan in
			WeatherCodeMan.code.contains(Int(data.current.weatherCode))
		})!.name)
		print(data.current.wind_speed_10m.formatted(.number.precision(.fractionLength(1))), "km/h")
		
		print ("hourly")
		dateFormatter.dateFormat = "HH:mm"
		for (i, date) in data.hourly.time.enumerated().prefix(24) {
			location.daily.append(DailyWeather(
				id: i,
				time: dateFormatter.string(from: date),
				temperature: data.hourly.temperature2m[i],
				wind_speed: data.hourly.wind_speed_10m[i],
				weather_code: weather_code_name.first(where: { WeatherCodeMan in
					WeatherCodeMan.code.contains(Int(data.hourly.weatherCode[i]))
				})!
			))
//			print(dateFormatter.string(from: date))
//			print(i)
//			print(data.hourly.temperature2m[i] , "°C")
//			print(data.hourly.wind_speed_10m[i], "km/h")
//			print(data.hourly.weatherCode[i])
			print(dateFormatter.string(from: date),
				data.hourly.temperature2m[i].formatted(.number.precision(.fractionLength(1))) , "°C",
				weather_code_name.first(where: { WeatherCodeMan in
					WeatherCodeMan.code.contains(Int(data.hourly.weatherCode[i]))
				})!.name,
				data.hourly.wind_speed_10m[i].formatted(.number.precision(.fractionLength(1))), "km/h")
		}

		print ("Week")
		dateFormatter.dateFormat = "yyyy-MM-dd"
		for (i, date) in data.daily.time.enumerated() {
			location.week.append(WeekWeather(
				id: i,
				date: dateFormatter.string(from: date),
				temperature_Max: data.daily.temperature2mMin[i],
				temperature_Min: data.daily.temperature2mMax[i],
				weather_code: weather_code_name.first(where: { WeatherCodeMan in
					WeatherCodeMan.code.contains(Int(data.daily.weatherCode[i]))
				})!
			))
		  print(dateFormatter.string(from: date),
				data.daily.temperature2mMin[i].formatted(.number.precision(.fractionLength(1))), "°C",
				data.daily.temperature2mMax[i].formatted(.number.precision(.fractionLength(1))), "°C",
				weather_code_name.first(where: { WeatherCodeMan in
					WeatherCodeMan.code.contains(Int(data.daily.weatherCode[i]))
				})!.name
		  )
		}
		return location
	}
}

