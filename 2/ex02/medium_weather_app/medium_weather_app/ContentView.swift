//
//  ContentView.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
	@StateObject var locationManager = LocationManager()
	@State var location : Location = Location(IsGPS: true, IsErrorGPS: false, IsErrorSearch: false)
	@State var IdActiveButton : Int = 0
	var content = [Content(id: 0, content: "Currently"),
				Content(id: 1, content: "Today"),
				Content(id: 2, content: "Weekly")]
	
	var body: some View {
		GeometryReader { geometry in
			let width : CGFloat = geometry.size.width
			let height : CGFloat = geometry.size.height
			let isPortrait : Bool = height > width
			VStack {
				AppBar(locationManager: locationManager, location: $location, isPortrait: isPortrait)
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
