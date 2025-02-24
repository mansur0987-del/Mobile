//
//  ContentView.swift
//  advanced_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
	@StateObject var locationManager = LocationManager()
	@State var location : Location = Location()
	@State var IdActiveButton : Int = 0
	var body: some View {
		GeometryReader { geometry in
			let width : CGFloat = geometry.size.width
			let height : CGFloat = geometry.size.height
			let isPortrait : Bool = height > width
			VStack {
				AppBar(locationManager: locationManager, location: $location, isPortrait: isPortrait)
					.frame(width: width, height: height * 0.05)
					.padding()
					.zIndex(1.0)
								
				TextPlace(IdActiveButton : $IdActiveButton, location: $location, locationManager: locationManager, isPortait: isPortrait)
					.font(.largeTitle)
					.frame(width: width, height: isPortrait ? height * 0.7 : height * 0.6)
					.contentShape(Rectangle())
					.zIndex(0)
					
				Spacer()
				ButtonBar(IdActiveButton: $IdActiveButton)
					.frame(width: width, height: isPortrait ? height * 0.1 : height * 0.2)
					.zIndex(0)
			}
			.frame(minWidth: width * 0.9, maxWidth: width, minHeight: height * 0.9, maxHeight: height)
			.padding()
			
			
		}
		.preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
		.task {
			locationManager.requestLocation()
		}
		.background(Image("background")
			.resizable()
			.scaledToFill()
			.ignoresSafeArea())
	}
}

#Preview {
	ContentView()
}
