//
//  AppBar.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import SwiftUI

struct AppBar: View {
	@ObservedObject var locationManager : LocationManager
	@Binding var location : Location
	var isPortrait : Bool
	var body: some View {
		HStack {
			SearchField(location: $location, isPortrait: isPortrait)
			Spacer()
			ButtonGPS(locationManager: locationManager, location: $location)
		}
	}
}

struct SearchField: View {
	@State var isDropdownVisible = false
	@State var options : [SearchData] = []
	@Binding var location : Location
	var isPortrait : Bool
	var network = Network()
	
	var body: some View {
		TextField("Location", text: $location.location)
			.font(.title2)
			.padding()
			.background(Color.gray.tertiary)
			.clipShape(RoundedRectangle(cornerRadius: 30))
			.onChange(of: location.location) { oldValue, newValue in
				if newValue.count > 0 {
					Task {
						do {
							options = try await network.Search(line: newValue)
							location.errorSearch = location.errorSearch == "Network error. Check internet connection" ? "" : location.errorSearch
						}
						catch {
							location.errorSearch = "Network error. Check internet connection"
						}
					}
				}
			}
			.onTapGesture {
				isDropdownVisible = true
			}
			.onSubmit {
				location = FindOneSearchResult(options: options, location: location)
				isDropdownVisible = false
				location.IsGPS = false
				if location.latitude != nil, location.longitude != nil {
					Task {
						do {
							location = try await network.GetWeather(latitude: location.latitude!, longitude: location.longitude!, location: location)
						}
						catch {
							location.errorSearch = "Network error. Check internet connection"
						}
					}
				}
			}
			.overlay {
				if isDropdownVisible, location.location.count > 1 {
					DropdownList(isDropdownVisible: $isDropdownVisible, isPortrait: isPortrait, options : $options, location: $location)
				}
			}
	}
}

struct DropdownList : View {
	@Binding var isDropdownVisible : Bool
	var isPortrait : Bool
	@Binding var options : [SearchData]
	@Binding var location : Location
	var body: some View {
		GeometryReader {geometry in
			@State var height : CGFloat = geometry.size.height
			VStack {
				List(self.options.prefix(5), id: \.self) { option in
					DropdownListText(option: option, isDropdownVisible: $isDropdownVisible, location: $location)
				}
				.scrollContentBackground(.hidden)
				.frame(height: isPortrait ? height * 5 : height * 5)
				.padding(0)
				.cornerRadius(8)
				.shadow(radius: 5)
			}
			.offset(y: isPortrait ? height * 0.5 : height * 0.5)
		}

		
	}
}

struct DropdownListText : View {
	var network = Network()
	@State var option : SearchData
	@Binding var isDropdownVisible : Bool
	@Binding var location : Location
	var body: some View {
		Text(CollectName(line_1: option.admin1, line_2: option.admin2, line_3: option.admin3, line_4: option.admin4, country: option.country))
			.frame(maxWidth: .infinity, alignment: .leading)
			.onTapGesture {
				location.location = ""
				location.final_location = CollectName(line_1: option.admin1, line_2: option.admin2, line_3: option.admin3, line_4: option.admin4, country: option.country)
				location.latitude = option.latitude
				location.longitude = option.longitude
				location.errorSearch = ""
				isDropdownVisible = false
				location.IsGPS = false
				Task {
					do {
						location = try await network.GetWeather(latitude: location.latitude!, longitude: location.longitude!, location: location)
					}
					catch {
						location.errorSearch = "Network error. Check internet connection"
					}
				}
			}
			.foregroundStyle(Color.gray)
			.listRowBackground(Color(UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)))
			.listRowSeparatorTint(Color.black)
	}
}

struct ButtonGPS: View {
	var network = Network()
	@ObservedObject var locationManager : LocationManager
	@Binding var location : Location
	var body: some View {
		Button(action: {
			Task {
				print("request GPS")
				locationManager.requestLocation()
				location.IsGPS = true
				
			}
		}, label: {
			Image(systemName: "location")
				.foregroundStyle(.gray)
		})
		.padding()
	}
}
