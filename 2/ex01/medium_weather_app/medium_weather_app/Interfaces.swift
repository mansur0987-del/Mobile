//
//  Interfaces.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/19/25.
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
	var IsGPS : Bool = false
	var location : String = ""
	var latitude : Double?
	var longitude : Double?
	var IsErrorGPS : Bool = false
	var errorGPS : String?
	var IsErrorSearch : Bool = false
	var errorSearch : String?
	
	init(IsGPS: Bool, latitude: Double? = nil, longitude: Double? = nil, IsErrorGPS: Bool, errorGPS: String? = nil, IsErrorSearch: Bool, errorSearch: String? = nil) {
		self.IsGPS = IsGPS
		self.latitude = latitude
		self.longitude = longitude
		self.IsErrorGPS = IsErrorGPS
		self.errorGPS = errorGPS
		self.IsErrorSearch = IsErrorSearch
		self.errorSearch = errorSearch
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
