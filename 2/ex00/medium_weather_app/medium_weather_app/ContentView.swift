//
//  ContentView.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/18/25.
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
			VStack {
				AppBar(locationManager: locationManager, location: $location)
					.frame(width: width, height: height * 0.05)
					.padding()
								
				TextPlace(IdActiveButton : $IdActiveButton, location: $location, locationManager: locationManager, content: content)
					.font(.largeTitle)
					.frame(width: width, height: height > width ? height * 0.7 : height * 0.6)
					.contentShape(Rectangle())
				Spacer()
				ButtonBar(IdActiveButton: $IdActiveButton)
					.frame(width: width, height: height > width ? height * 0.1 : height * 0.2)
			}
			
			.frame(minWidth: width * 0.9, maxWidth: width, minHeight: height * 0.9, maxHeight: height)
			.padding()
			
			.gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
				.onEnded { value in
					print(value.translation)
					switch(value.translation.width, value.translation.height) {
					case (...0, -30...30):  print("left swipe"); IdActiveButton = IdActiveButton == 2 ? IdActiveButton : IdActiveButton + 1;
					case (0..., -30...30):  print("right swipe");
						IdActiveButton = IdActiveButton == 0 ? IdActiveButton : IdActiveButton - 1
					default:  print("no clue")
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
	@State var IsLoading : Bool = false
	var body: some View {
		HStack {
			TextField("Location", text: $location.location)
				.font(.title2)
				.padding()
				.background(Color.gray.tertiary)
				.clipShape(RoundedRectangle(cornerRadius: 30))
				.onChange(of: location.location) { oldValue, newValue in
					location.IsErrorGPS = false
					location.IsGPS = newValue != "" ? false : location.IsGPS
				}
			
			Spacer()
			ButtonGPS(locationManager: locationManager, location: $location)
		}
		
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

