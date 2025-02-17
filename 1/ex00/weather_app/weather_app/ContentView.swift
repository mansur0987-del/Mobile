//
//  ContentView.swift
//  weather_app
//
//  Created by Mansur Kakushkin on 2/17/25.
//

import SwiftUI

struct ContentView: View {
	@State var location : String = ""
	@State var IdActiveButton : Int = 0
	var content = [Content(id: 0, content: "Currently"),
				Content(id: 1, content: "Today"),
				Content(id: 2, content: "Weekly")]
    var body: some View {
		GeometryReader { geometry in
			@State var width : CGFloat = geometry.size.width
			@State var height : CGFloat = geometry.size.height
			VStack {
				AppBar(location: $location)
					.frame(width: width, height: height * 0.05)
					.padding()
								
				TextPlace(IdActiveButton : $IdActiveButton, content: content)
					.font(.largeTitle)
					.frame(width: width, height: height * 0.7)
					.padding()
				
				ButtonBar(IdActiveButton: $IdActiveButton)
					.frame(width: width,  alignment: .bottom)
			}
			
			.frame(minWidth: width * 0.9, maxWidth: width, minHeight: height * 0.9, maxHeight: height)
			.padding()
			.contentShape(Rectangle())
			.gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
				.onEnded { value in
					print(value.translation)
					switch(value.translation.width, value.translation.height) {
					case (...0, -30...30):  print("left swipe"); IdActiveButton = IdActiveButton == 2 ? IdActiveButton : IdActiveButton + 1;
					case (0..., -30...30):  print("right swipe");
						IdActiveButton = IdActiveButton == 0 ? IdActiveButton : IdActiveButton - 1

						case (-100...100, ...0):  print("up swipe")
						case (-100...100, 0...):  print("down swipe")
						default:  print("no clue")
					}
				}
			)
			
		}
		.preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ContentView()
}

struct AppBar: View {
	@Binding var location : String
	var body: some View {
		HStack {
			TextField("Location", text: $location)
				.font(.title2)
				.padding()
				.background(Color.gray.tertiary)
				.clipShape(RoundedRectangle(cornerRadius: 30))
			Spacer()
			Button(action: {
			}, label: {
				Image(systemName: "location")
					.foregroundStyle(.gray)
			})
			.padding()
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
				Button(action: {
					IdActiveButton = 0
				}, label: {
					VStack {
						Image(systemName: "timer")
							.foregroundStyle(.gray)
						Text("Currently")
							.foregroundStyle(.gray)
					}
					.font(.callout)
					.padding()
					.background(IdActiveButton == 0 ? Color.black : Color.clear)
					.clipShape(RoundedRectangle(cornerRadius: 30))
				})
				.frame(width: width * 0.3)
				Spacer()
				Button(action: {
					IdActiveButton = 1
				}, label: {
					VStack {
						Image(systemName: "calendar")
							.foregroundStyle(.gray)
						Text("Today")
							.foregroundStyle(.gray)
					}
					.font(.callout)
					.padding()
					.background(IdActiveButton == 1 ? Color.black : Color.clear)
					.clipShape(RoundedRectangle(cornerRadius: 30))
				})
				.frame(width: width * 0.3)
				Spacer()
				
				Button(action: {
					IdActiveButton = 2
				}, label: {
					VStack {
						Image(systemName: "calendar.badge.plus")
							.foregroundStyle(.gray)
						Text("Weekly")
							.foregroundStyle(.gray)
					}
					.font(.callout)
					.padding()
					.background(IdActiveButton == 2 ? Color.black : Color.clear)
					.clipShape(RoundedRectangle(cornerRadius: 30))
				})
				.frame(width: width * 0.3)
			}
			.frame(width: width * 0.9)
			.padding()
			.background(Color.gray.tertiary)
			.clipShape(RoundedRectangle(cornerRadius: 30))
		}
	}
}



struct TextPlace: View {
	@Binding var IdActiveButton : Int
	var content : [Content]
	var body: some View {
		Text(content[IdActiveButton].content)
	}
}
struct Content : Codable {
	var id: Int
	var content : String
	
	init(id: Int, content: String) {
		self.id = id
		self.content = content
	}
}
