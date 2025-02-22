//
//  TextPlace.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import SwiftUI

struct TextPlace: View {
	var network = Network()
	@Binding var IdActiveButton : Int
	@Binding var location : Location
	@ObservedObject var locationManager : LocationManager
	var isPortait : Bool
	var body: some View {
		VStack {
			if CheckerIsErrors(location: location, locationManager: locationManager) != "OK" {
				ErrorView(ErrorMsg: CheckerIsErrors(location: location, locationManager: locationManager))
			}
			else {
				if location.IsGPS == true {
					if locationManager.location != nil {
						Text(locationManager.location ?? "")
							.font(.system(size: 30))
							.task {
								do {
									location.errorGetWeather = ""
									location = try await network.GetWeather(latitude: locationManager.latitude!, longitude: locationManager.longitude!, location: location)
								}
								catch {
									location.errorGetWeather = "Network error. Check internet connection"
								}
							}
					}
				}
				else {
					Text(location.final_location)
						.font(.system(size: 30))
				}
				if IdActiveButton == 0, location.current != nil {
					CurrentView(location : $location)
				}
				else if IdActiveButton == 1 {
					if isPortait {
						ForEach(location.daily , id: \.id) { el in
							HStack {
								Text(el.time)
								Text(el.temperature.formatted(.number.precision(.fractionLength(1))) + " °C")
								Text(el.wind_speed.formatted(.number.precision(.fractionLength(1))) + " km/h")
								Text(el.weather_code.name)
							}.font(.system(size: 15))
						}
					}
					else {
						HStack {
							VStack {
								ForEach(location.daily.prefix(12) , id: \.id) { el in
									HStack {
										Text(el.time)
										Text(el.temperature.formatted(.number.precision(.fractionLength(1))) + " °C")
										Text(el.wind_speed.formatted(.number.precision(.fractionLength(1))) + " km/h")
										Text(el.weather_code.name)
									}
								}
							}
							VStack {
								ForEach(location.daily.suffix(12), id: \.id) { el in
									HStack {
										Text(el.time)
										Text(el.temperature.formatted(.number.precision(.fractionLength(1))) + " °C")
										Text(el.wind_speed.formatted(.number.precision(.fractionLength(1))) + " km/h")
										Text(el.weather_code.name)
									}
									
								}
							}
						}.font(.system(size: 15))
					}
				}
				else {
					ForEach(location.week , id: \.id) { el in
						HStack {
							Text(el.date)
							Text(el.temperature_Min.formatted(.number.precision(.fractionLength(1))) + " °C")
							Text(el.temperature_Max.formatted(.number.precision(.fractionLength(1))) + " °C")
							Text(el.weather_code.name)
						}
						.font(.system(size: 15))
					}
				}
			}
			
		}
		.font(.title3)
	}
}

struct CurrentView :View {
	@Binding var location : Location
	var body: some View {
		VStack {
			Text(location.current!.temperature.formatted(.number.precision(.fractionLength(1))) + " °C")
				.font(.system(size: 40))
				.foregroundStyle(Color.yellow)
			Text(location.current!.weather_code.name)
				.font(.system(size: 30))
			Text(.init(systemName: location.current!.weather_code.icon_name))
				.font(.system(size: 50))
				.foregroundStyle(.blue)
			HStack {
				Text(.init(systemName: "wind"))
					.foregroundStyle(.blue)
				Text(location.current!.wind_speed.formatted(.number.precision(.fractionLength(1))) + " km/h")
			}.font(.system(size: 30))
			
		}
	}
}

struct ErrorView : View {
	var ErrorMsg : String
	var body: some View {
		Text(ErrorMsg)
			.foregroundStyle(.red)
			.font(.system(size: 30))
		
	}
}
