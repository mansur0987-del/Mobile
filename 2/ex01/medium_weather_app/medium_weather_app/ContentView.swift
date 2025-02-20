//
//  ContentView.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/19/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
	@StateObject var locationManager = LocationManager()
	@State var location : Location = Location(IsGPS: false, IsErrorGPS: false, IsErrorSearch: false)
	@State var IdActiveButton : Int = 0
	var content = [Content(id: 0, content: "Currently"),
				Content(id: 1, content: "Today"),
				Content(id: 2, content: "Weekly")]
	
	var body: some View {
		GeometryReader { geometry in
			@State var width : CGFloat = geometry.size.width
			@State var height : CGFloat = geometry.size.height
			@State var isPortrait : Bool = height > width
			VStack {
				AppBar(locationManager: locationManager, location: $location, isPortrait: $isPortrait)
					.frame(width: width, height: height * 0.05)
					.padding()
								
				TextPlace(IdActiveButton : $IdActiveButton, location: $location, locationManager: locationManager, content: content)
					.font(.largeTitle)
					.frame(width: width, height: isPortrait ? height * 0.7 : height * 0.6)
					.contentShape(Rectangle())
				Spacer()
				ButtonBar(IdActiveButton: $IdActiveButton)
					.frame(width: width, height: isPortrait ? height * 0.1 : height * 0.2)
			}
			.frame(minWidth: width * 0.9, maxWidth: width, minHeight: height * 0.9, maxHeight: height)
			.padding()
			
			.gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
				.onEnded { value in
					switch(value.translation.width, value.translation.height) {
					case (...0, -30...30):  IdActiveButton = IdActiveButton == 2 ? IdActiveButton : IdActiveButton + 1;
					case (0..., -30...30):	IdActiveButton = IdActiveButton == 0 ? IdActiveButton : IdActiveButton - 1
					default: break
					}
				}
			)
		}
		.preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
		.task {
			locationManager.requestLocation()
		}
	}
}

#Preview {
	ContentView()
}

struct AppBar: View {
	@ObservedObject var locationManager : LocationManager
	@Binding var location : Location
	@Binding var isPortrait : Bool
	var body: some View {
		HStack {
			SearchField(location: $location, isPortrait: $isPortrait)
			Spacer()
			ButtonGPS(locationManager: locationManager, location: $location)
		}
	}
}

struct SearchField: View {
	@State var isDropdownVisible = false
	@State var options : [SearchData] = []
	@Binding var location : Location
	@Binding var isPortrait : Bool
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
							print ("result_search: ", options.prefix(5))
							isDropdownVisible = true
						}
						catch {
							location.errorSearch = "Network error. Check internet connection"
							print("Error: ", error)
						}
						location.IsGPS = newValue != "" ? false : location.IsGPS
					}
				}
			}
			.onTapGesture {
				isDropdownVisible.toggle()
			}
			.onSubmit {
				isDropdownVisible.toggle()
			}
			.overlay {
				if isDropdownVisible {
					DropdownList(isDropdownVisible: $isDropdownVisible, isPortrait: $isPortrait, options : $options, location: $location)
				}
			}
	}
}

struct DropdownList : View {
	@Binding var isDropdownVisible : Bool
	@Binding var isPortrait : Bool
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
			.offset(y: isPortrait ? height : height * 0.5)
		}

		
	}
}

struct DropdownListText : View {
	@State var option : SearchData
	@Binding var isDropdownVisible : Bool
	@Binding var location : Location
	var body: some View {
		Text(CollectName(line_1: option.admin1, line_2: option.admin2, line_3: option.admin3, line_4: option.admin4, country: option.country))
			.frame(maxWidth: .infinity, alignment: .leading)
			.onTapGesture {
				isDropdownVisible = false
				location.location = CollectName(line_1: option.admin1, line_2: option.admin2, line_3: option.admin3, line_4: option.admin4, country: option.country)
				location.latitude = option.latitude
				location.longitude = option.longitude
			}
			.foregroundStyle(Color.gray)
			.listRowBackground(Color(UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)))
			.listRowSeparatorTint(Color.black)
	}
}

struct ButtonGPS: View {
	@ObservedObject var locationManager : LocationManager
	@Binding var location : Location
	var body: some View {
		Button(action: {
			Task {
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
					Text(location.location)
				}
			}
		}
	}
}

struct ButtonBar: View {
	@Binding var IdActiveButton : Int
	var body: some View {
		GeometryReader {geometry in
			@State var width : CGFloat = geometry.size.width
			@State var height : CGFloat = geometry.size.height
			HStack {
				ButtonCurrently(IdActiveButton : $IdActiveButton)
					.frame(width: width * 0.3)
				Spacer()
				ButtonToday(IdActiveButton : $IdActiveButton)
					.frame(width: width * 0.3)
				Spacer()
				ButtonWeekly(IdActiveButton : $IdActiveButton)
					.frame(width: width * 0.3)
			}
			.frame(width: width * 0.9)
			.padding()
			.background(Color.gray.tertiary)
			.clipShape(RoundedRectangle(cornerRadius: 30))
		}
	}
}
