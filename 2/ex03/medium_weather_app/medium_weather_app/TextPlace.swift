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
			if location.IsGPS == true {
				if locationManager.error != nil {
					Text(locationManager.error!)
					.foregroundStyle(.red)
					.task {
						location = LocationWaetherClean(location: location)
						locationManager.location = nil
					}
				}
				else if locationManager.location != nil {
					Text(locationManager.location ?? "")
					.task {
						do {
							location = try await network.GetWeather(latitude: locationManager.latitude!, longitude: locationManager.longitude!, location: location)
						}
						catch {
							locationManager.location = nil
							locationManager.error = "Network error. Check internet connection"
							location.errorSearch = "Network error. Check internet connection"
							location = LocationWaetherClean(location: location)
						}
					}
				}
			}
			else {
				if location.errorSearch != "" {
					Text(location.errorSearch)
						.foregroundStyle(.red)
						.task {
							location = LocationWaetherClean(location: location)
						}
				}
				else {
					Text(location.final_location)
				}
			}
			
			if IdActiveButton == 0, location.current != nil {
				VStack {
					Text(location.current!.temperature.formatted(.number.precision(.fractionLength(1))) + " °C")
					Text(location.current!.wind_speed.formatted(.number.precision(.fractionLength(1))) + " km/h")
					Text(location.current!.weather_code.name)
				}.font(.system(size: 15))
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
		.font(.title3)
	}
}
