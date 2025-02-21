//
//  ButtonBar.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import SwiftUI

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

struct ButtonCurrently: View {
	@Binding var IdActiveButton : Int
	var body: some View {
		Button(action: {
			IdActiveButton = 0
		}, label: {
			VStack {
				Image(systemName: "timer")
					.foregroundStyle(.white)
				Text("Currently")
					.foregroundStyle(.white)
			}
			.font(.callout)
			.padding()
			.background(IdActiveButton == 0 ? Color.black : Color.clear)
			.clipShape(RoundedRectangle(cornerRadius: 30))
		})
	}
}

struct ButtonToday: View {
	@Binding var IdActiveButton : Int
	var body: some View {
		Button(action: {
			IdActiveButton = 1
		}, label: {
			VStack {
				Image(systemName: "calendar")
					.foregroundStyle(.white)
				Text("Today")
					.foregroundStyle(.white)
			}
			.font(.callout)
			.padding()
			.background(IdActiveButton == 1 ? Color.black : Color.clear)
			.clipShape(RoundedRectangle(cornerRadius: 30))
		})
	}
}

struct ButtonWeekly: View {
	@Binding var IdActiveButton : Int
	var body: some View {
		Button(action: {
			IdActiveButton = 2
		}, label: {
			VStack {
				Image(systemName: "calendar.badge.plus")
					.foregroundStyle(.white)
				Text("Weekly")
					.foregroundStyle(.white)
			}
			.font(.callout)
			.padding()
			.background(IdActiveButton == 2 ? Color.black : Color.clear)
			.clipShape(RoundedRectangle(cornerRadius: 30))
		})
	}
}
