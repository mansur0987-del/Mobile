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
						.gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
							.onEnded { value in
								IdActiveButton = handleSwipeGesture(value: value, IdActiveButton: IdActiveButton)
							}
						)
				}
				else if IdActiveButton == 1, location.daily.count > 0 {
					DailyView(daily : $location.daily, IdActiveButton: $IdActiveButton)
				}
				else if IdActiveButton == 2, location.week.count > 0 {
					WeekView(week: $location.week, IdActiveButton: $IdActiveButton)
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
	@Binding var daily : [DailyWeather]
	@Binding var IdActiveButton : Int
	var body: some View {
		GeometryReader {geometry in
			if geometry.size.height > geometry.size.width {
				VStack {
					DiagramDailyView(daily : $daily)
						.gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
							.onEnded { value in
								IdActiveButton = handleSwipeGesture(value: value, IdActiveButton: IdActiveButton)
							}
						)
						.zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
					DailyListView(daily : $daily)
						.zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
				}
			}
			else {
				HStack {
					DiagramDailyView(daily : $daily)
						.gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
							.onEnded { value in
								IdActiveButton = handleSwipeGesture(value: value, IdActiveButton: IdActiveButton)
							}
						)
						.zIndex(1.0)
					DailyListView(daily : $daily)
						.zIndex(0)
				}
			}
		}
	}
}

struct DiagramDailyView :View {
	@Binding var daily : [DailyWeather]
	var body: some View {
		VStack {
			Text("Today temperatures").font(.system(size: 20)).foregroundStyle(.white)
			Chart(daily, id: \.id) {el in
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
					if let number = value.as(Double.self) {
						AxisValueLabel {
							Text("\(number, specifier: "%.1f") °C")
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
	}
}

struct DailyListView :View {
	@Binding var daily : [DailyWeather]
	var body: some View {
		ScrollView (.horizontal) {
			HStack {
				ForEach(daily, id: \.id) { el in
					VStack {
						Text(el.time_string)
							.font(.system(size: 15))
						Text(el.temperature.formatted(.number.precision(.fractionLength(1))) + " °C")
							.font(.system(size: 15))
							.foregroundStyle(Color.yellow)
						Text(.init(systemName: el.weather_code.icon_name))
							.font(.system(size: 15))
							.foregroundStyle(.blue)
						HStack {
							Text(.init(systemName: "wind"))
								.foregroundStyle(.blue)
							Text(el.wind_speed.formatted(.number.precision(.fractionLength(1))) + " km/h")
						}.font(.system(size: 15))
					}
					.padding()
					.background(Color.gray.tertiary)
					.cornerRadius(20)
					.shadow(radius: 5)
				}
			}
		}
	}
}


struct WeekView : View {
	@Binding var week : [WeekWeather]
	@Binding var IdActiveButton : Int
	var body: some View {
		GeometryReader {geometry in
			if geometry.size.height > geometry.size.width {
				VStack {
					DiagramWeekView(week : $week)
						.gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
							.onEnded { value in
								IdActiveButton = handleSwipeGesture(value: value, IdActiveButton: IdActiveButton)
							}
						)
						.zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
					WeekListView(week : $week)
						.zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
				}
			}
			else {
				HStack {
					DiagramWeekView(week : $week)
						.gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
							.onEnded { value in
								IdActiveButton = handleSwipeGesture(value: value, IdActiveButton: IdActiveButton)
							}
						)
						.zIndex(1.0)
					WeekListView(week : $week)
						.zIndex(0)
				}
			}
		}
	}
}

struct DiagramWeekView :View {
	@Binding var week : [WeekWeather]
	var body: some View {
		VStack {
			Text("Weekly temperatures").font(.system(size: 20)).foregroundStyle(.white)
			Chart (week, id: \.id) {el in
				LineMark(
					x: .value("Time", el.date),
					y: .value("Temperature max", el.temperature_Max),
					series: .value("Max", "A")
				)
				.foregroundStyle(.red)
				.interpolationMethod(.catmullRom)
				
				PointMark(
					x: .value("Time", el.date),
					y: .value("Temperature", el.temperature_Max)
				)
				.foregroundStyle(.orange)
			
				LineMark(
					x: .value("Time", el.date),
					y: .value("Temperature min", el.temperature_Min),
					series: .value("Min", "B")
				)
				.foregroundStyle(.blue)
				.interpolationMethod(.catmullRom)
				
				PointMark(
					x: .value("Time", el.date),
					y: .value("Temperature", el.temperature_Min)
				)
				.foregroundStyle(.orange)
			}
			.chartForegroundStyleScale([
					"Temperature max": Color.red,
					"Temperature min": Color.blue
			])
			.chartLegend(alignment: .bottom)
			.chartXAxis {
				AxisMarks(preset: .aligned, values: .stride(by: .day)) { value in
					 if let date = value.as(Date.self) {
						let dateFormatter: DateFormatter = {
							 let formatter = DateFormatter()
							 formatter.dateFormat = "dd/MM"
							 formatter.timeZone = TimeZone(secondsFromGMT: 0)
							 print(formatter.string(from: date))
							 return formatter
						 }()
						 let formattedDate = dateFormatter.string(from: date)
						 AxisValueLabel (multiLabelAlignment: .center) {
							 Text("\(formattedDate)")
								.font(.system(size: 10))
								.foregroundStyle(.white)
								.offset(x: -40)
						 }
					}
					AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
					AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
				 }
			}
			.chartXScale(domain: week[0].date...week[6].date)
			.chartYAxis{
				AxisMarks(position: .leading) { value in
					if let number = value.as(Double.self) {
						AxisValueLabel {
							Text("\(number, specifier: "%.1f") °C")
								.font(.system(size: 10))
								.foregroundStyle(.white)
						}
					}
					AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
					AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
				}
			}
			.foregroundStyle(.white)
			.padding()
		}
		.background(Color.gray.tertiary)
		.cornerRadius(20)
		.shadow(radius: 5)
	}
}

struct WeekListView :View {
	@Binding var week : [WeekWeather]
	var body: some View {
		ScrollView (.horizontal) {
			HStack {
				ForEach(week, id: \.id) { el in
					VStack {
						Text(el.date_string)
							.font(.system(size: 15))
						Text(el.temperature_Max.formatted(.number.precision(.fractionLength(1))) + " °C")
							.font(.system(size: 15))
							.foregroundStyle(Color.red)
						Text(el.temperature_Min.formatted(.number.precision(.fractionLength(1))) + " °C")
							.font(.system(size: 15))
							.foregroundStyle(Color.blue)
						Text(.init(systemName: el.weather_code.icon_name))
							.font(.system(size: 15))
							.foregroundStyle(.blue)
					}
					.padding()
					.background(Color.gray.tertiary)
					.cornerRadius(20)
					.shadow(radius: 5)
				}
			}
		}
	}
}



func handleSwipeGesture(value: DragGesture.Value, IdActiveButton : Int) -> Int {
	var IdActiveButton = IdActiveButton
	switch (value.translation.width, value.translation.height) {
	case (...0, -30...30):
		IdActiveButton = IdActiveButton == 2 ? IdActiveButton : IdActiveButton + 1
	case (0..., -30...30):
		IdActiveButton = IdActiveButton == 0 ? IdActiveButton : IdActiveButton - 1
	default:
		break
	}
	return IdActiveButton
}
