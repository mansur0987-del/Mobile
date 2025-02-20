//
//  ButtonBar.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import SwiftUI

struct ButtonCurrently: View {
	@Binding var IdActiveButton : Int
	var body: some View {
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
					.foregroundStyle(.gray)
				Text("Today")
					.foregroundStyle(.gray)
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
					.foregroundStyle(.gray)
				Text("Weekly")
					.foregroundStyle(.gray)
			}
			.font(.callout)
			.padding()
			.background(IdActiveButton == 2 ? Color.black : Color.clear)
			.clipShape(RoundedRectangle(cornerRadius: 30))
		})
	}
}
