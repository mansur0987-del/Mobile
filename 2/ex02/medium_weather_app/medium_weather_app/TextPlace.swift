//
//  TextPlace.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import SwiftUI

struct TextPlace: View {
	@Binding var IdActiveButton : Int
	@Binding var location : Location
	@ObservedObject var locationManager : LocationManager
	var content : [Content]
	var body: some View {
		VStack {
			if location.IsGPS == true {
				if locationManager.error != nil {
					Text(locationManager.error!)
						.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
						.foregroundStyle(.red)
				}
				else if locationManager.latitude != nil , locationManager.longitude != nil {
					Text(content[IdActiveButton].content)
					Text(String(locationManager.latitude!) + " " + String(locationManager.longitude!))
				}
			}
			else {
				if location.IsErrorSearch {
					Text(location.errorSearch!)
						.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
						.foregroundStyle(.red)
				}
				else {
					Text(content[IdActiveButton].content)
					if location.latitude != nil, location.longitude != nil {
						Text(String(location.latitude!) + " " + String(location.longitude!))
					}
				}
			}
		}
	}
}
