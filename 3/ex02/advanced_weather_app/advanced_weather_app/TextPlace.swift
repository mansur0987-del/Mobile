//
//  TextPlace.swift
//  advanced_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import SwiftUI
import Charts

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
				else if IdActiveButton == 1, location.daily.count > 0 {
					DailyView(location : $location)
				}
				else if IdActiveButton == 2, location.week.count > 0 {
					WeekView(location: $location)
				}
				else {
					ErrorView(ErrorMsg: "Network error. Check internet connection")
				}
			}
			
		}
		.font(.title3)
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

struct DailyView : View {
	@Binding var location : Location
	var body: some View {
		VStack {
			Text("Today temperatures").font(.system(size: 20)).foregroundStyle(.white)
			Chart(location.daily, id: \.id) {el in
				LineMark(
					x: .value("Time", el.time),
					y: .value("Temperature", el.temperature)
				)
				.foregroundStyle(.blue)
				.interpolationMethod(.catmullRom)
				PointMark(
					x: .value("Time", el.time),
					y: .value("Temperature", el.temperature)
				)
				.foregroundStyle(.orange)
			}
			.chartXAxis {
				 AxisMarks(values: .stride(by: .hour, count: 6)) { value in
					 if let date = value.as(Date.self) {
						 let gmtCalendar = {
							var gmtCalendar = Calendar.current
							gmtCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
							return gmtCalendar
						 }()
						 let hour = gmtCalendar.component(.hour, from: date)
						 AxisValueLabel{
							 Text("\(hour):00")
								.font(.system(size: 10))
								.foregroundStyle(.white)
						}
					}
					AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
					AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
				 }
			 }
			.chartYAxis{
				AxisMarks(position: .leading) { value in
					if let number = value.as(Double.self) {  // Преобразуем значение в число
						AxisValueLabel {
							Text("\(number, specifier: "%.1f") °C")  // Добавляем "°C" к числу
								.font(.system(size: 10))
								.foregroundStyle(.white)
						}
					}
					AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
					AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
				}
			}
			.padding()
		}
		.background(Color.gray.tertiary)
		.cornerRadius(20)
		.shadow(radius: 5)
		
//		ForEach(location.daily , id: \.id) { el in
//			HStack {
//				Text(el.time)
//				Text(el.temperature.formatted(.number.precision(.fractionLength(1))) + " °C")
//				Text(el.wind_speed.formatted(.number.precision(.fractionLength(1))) + " km/h")
//				Text(el.weather_code.name)
//			}.font(.system(size: 15))
//		}
	}
}



struct WeekView : View {
	@Binding var location : Location
	var body: some View {
		ForEach(location.week , id: \.id) { el in
			HStack {
//				Text(el.date)
				Text(el.temperature_Min.formatted(.number.precision(.fractionLength(1))) + " °C")
				Text(el.temperature_Max.formatted(.number.precision(.fractionLength(1))) + " °C")
				Text(el.weather_code.name)
			}
			.font(.system(size: 15))
		}
	}
}
