//
//  Utils.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import Foundation

func CollectName(line_1: String?, line_2: String?, line_3: String?, line_4: String?, country: String?) -> String {
	var collect : String = ""
	if line_1 != nil {
		collect = line_1! + ", "
	}
	if line_2 != nil {
		collect = collect + line_2! + ", "
	}
	if line_3 != nil {
		collect = collect + line_3! + ", "
	}
	if line_4 != nil {
		collect = collect + line_4! + ", "
	}
	if country != nil {
		collect = collect + country!
	}
	
	return collect
}
