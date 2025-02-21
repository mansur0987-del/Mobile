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
