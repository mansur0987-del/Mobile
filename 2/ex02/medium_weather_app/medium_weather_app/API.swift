//
//  API.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import Combine
import Foundation

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
}

