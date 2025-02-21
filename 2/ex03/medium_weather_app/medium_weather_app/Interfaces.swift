//
//  Interfaces.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import Foundation

struct Content : Codable {
	var id: Int
	var content : String
	
	init(id: Int, content: String) {
		self.id = id
		self.content = content
	}
}

struct Location : Codable {
	var IsGPS : Bool = true
	var location : String = ""
	var final_location : String = ""
	var latitude : Double?
	var longitude : Double?
	var errorGPS : String = ""
	var errorSearch : String = ""
	var current : CurrentWeather?
	var daily : [DailyWeather] = []
	var week : [WeekWeather] = []
	
	init(IsGPS: Bool, latitude: Double? = nil, longitude: Double? = nil, IsErrorGPS: Bool, errorGPS: String? = nil, IsErrorSearch: Bool, errorSearch: String? = nil) {
		self.IsGPS = IsGPS
		self.latitude = latitude
		self.longitude = longitude
		self.errorGPS = errorGPS ?? ""
		self.errorSearch = errorSearch ?? ""
	}
}

struct ResultSearch : Decodable {
	var results : [SearchData]?
}

struct SearchData : Decodable, Hashable {
	var id : Int
	var admin1 : String?
	var admin2 : String?
	var admin3 : String?
	var admin4 : String?
	var country : String?
	var latitude : Double
	var longitude : Double
}

struct WeatherCodeMan : Codable {
	var id : Int
	var name : String
	var code : [Int]
	
	init(id: Int, name: String, code: [Int]) {
		self.id = id
		self.name = name
		self.code = code
	}
}

struct CurrentWeather : Codable {
	var temperature : Float
	var wind_speed : Float
	var weather_code : WeatherCodeMan
	
	init(temperature: Float, wind_speed: Float, weather_code: WeatherCodeMan) {
		self.temperature = temperature
		self.wind_speed = wind_speed
		self.weather_code = weather_code
	}
}

struct DailyWeather : Codable {
	var id : Int
	var time : String
	var temperature : Float
	var wind_speed : Float
	var weather_code : WeatherCodeMan
	
	init(id: Int, time: String, temperature: Float, wind_speed: Float, weather_code: WeatherCodeMan) {
		self.id = id
		self.time = time
		self.temperature = temperature
		self.wind_speed = wind_speed
		self.weather_code = weather_code
	}
}

struct WeekWeather : Codable {
	var id : Int
	var date : String
	var temperature_Max : Float
	var temperature_Min : Float
	var weather_code : WeatherCodeMan
	
	init(id: Int, date: String, temperature_Max: Float, temperature_Min: Float, weather_code: WeatherCodeMan) {
		self.id = id
		self.date = date
		self.temperature_Max = temperature_Max
		self.temperature_Min = temperature_Min
		self.weather_code = weather_code
	}
}

