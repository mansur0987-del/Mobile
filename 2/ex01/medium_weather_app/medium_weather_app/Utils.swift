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
		location.latitude = option.latitude
		location.longitude = option.longitude
		location.IsErrorSearch = false
		return location
	}
	location.latitude = nil
	location.longitude = nil
	location.IsErrorSearch = true
	location.errorSearch = "Location did not find"
	return location
}

