//
//  Utils.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import Foundation

func CollectName(line_1: String?, line_2: String?, line_3: String?, line_4: String?, country: String?) -> String {
	var collect : String = ""
	if line_4 != nil {
		collect = collect + line_4! + ", "
	}
	if line_3 != nil {
		collect = collect + line_3! + ", "
	}
	if line_2 != nil {
		collect = collect + line_2! + ", "
	}
	if line_1 != nil {
		collect = collect + line_1! + ", "
	}
	if country != nil {
		collect = collect + country!
	}
	return collect
}

func FindOneSearchResult(options: [SearchData], location: Location) -> Location {
	var location = location
	location.location = ""
	if options.count > 0 {
		let option = options[0]
		location.final_location = CollectName(line_1: option.admin1, line_2: option.admin2, line_3: option.admin3, line_4: option.admin4, country: option.country)
		location.latitude = option.latitude
		location.longitude = option.longitude
		location.errorSearch = ""
		return location
	}
	location.final_location = ""
	location.latitude = nil
	location.longitude = nil
	location.errorSearch = location.errorSearch == "" ? "Location did not find" : location.errorSearch
	return location
}

func LocationWaetherClean(location : Location) -> Location {
	var location = location
	location.current = nil
	location.daily = []
	location.week = []
	return location
}

var weather_code_name : [WeatherCodeMan] = [
	WeatherCodeMan(id: 0, name: "Clear sky", code: [0], icon_name: "sun.max"),
	WeatherCodeMan(id: 1, name: "Partly cloudy", code: [1, 2, 3], icon_name: "cloud"),
	WeatherCodeMan(id: 2, name: "Fog", code: [45, 48], icon_name: "cloud.fog.fill"),
	WeatherCodeMan(id: 3, name: "Drizzle", code: [51, 53, 55, 61, 63, 65], icon_name: "cloud.drizzle"),
	WeatherCodeMan(id: 4, name: "Rain", code: [66, 67, 80, 81, 82], icon_name: "cloud.rain"),
	WeatherCodeMan(id: 5, name: "Snow", code: [71, 73, 75, 77, 85, 86], icon_name: "cloud.snow"),
	WeatherCodeMan(id: 6, name: "Thunderstorm", code: [95, 96, 99], icon_name: "cloud.bolt.rain"),
]

func CheckerIsErrors (location: Location, locationManager: LocationManager) -> String {
	if location.IsGPS {
		print("Use GPS")
		if locationManager.error != nil {
			return locationManager.error!
		}
		if locationManager.location == nil || locationManager.latitude == nil || locationManager.longitude == nil {
			return "Loading location... \nIf it takes a long time, check ypur internet connection."
		}
	}
	else {
		print("Use NOT GPS")
		if location.final_location == "" || location.latitude == nil || location.longitude == nil {
			if location.errorSearch != "" {
				return location.errorSearch
			}
		}
	}
	if location.errorGetWeather != "" {
		return location.errorGetWeather
	}
	return "OK"
}
