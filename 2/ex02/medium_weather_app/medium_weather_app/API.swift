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
	
	func GetWeather(latitude : Double, longitude : Double) async throws {
		print("func Get Weather")
		guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,weather_code&hourly=temperature_2m,precipitation&daily=temperature_2m_min,temperature_2m_max&timezone=auto&format=flatbuffers")
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
		  }
		  struct Hourly {
			let time: [Date]
			let temperature2m: [Float]
			let precipitation: [Float]
		  }
		  struct Daily {
			let time: [Date]
			let temperature2mMax: [Float]
			let temperature2mMin: [Float]
		  }
		}

		/// Note: The order of weather variables in the URL query and the `at` indices below need to match!
		let data = WeatherData(
		  current: .init (
			time: Date(timeIntervalSince1970: TimeInterval(current.time + Int64(utcOffsetSeconds))),
			temperature2m: current.variables(at: 0)!.value,
			weatherCode: current.variables(at: 1)!.value
		  ),
		  hourly: .init(
			time: hourly.getDateTime(offset: utcOffsetSeconds),
			temperature2m: hourly.variables(at: 0)!.values,
			precipitation: hourly.variables(at: 1)!.values
		  ),
		  daily: .init(
			time: daily.getDateTime(offset: utcOffsetSeconds),
			temperature2mMax: daily.variables(at: 0)!.values,
			temperature2mMin: daily.variables(at: 1)!.values
		  )
		)

		/// Timezone `gmt` is deliberately used.
		/// By adding `utcOffsetSeconds` before, local-time is inferred
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = .gmt
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
		
		print("Current")
		print(dateFormatter.string(from: data.current.time))
		print(data.current.temperature2m)
		print(data.current.weatherCode)
		
		print ("hourly")
		for (i, date) in data.hourly.time.enumerated().prefix(24) {
		  print(dateFormatter.string(from: date))
		  print(data.hourly.temperature2m[i])
		  print(data.hourly.precipitation[i])
		}

		print ("daily")
		for (i, date) in data.daily.time.enumerated() {
		  print(dateFormatter.string(from: date))
		  print(data.daily.temperature2mMin[i])
		  print(data.daily.temperature2mMax[i])
		}
	}
}

