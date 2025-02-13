//
//  ContentView.swift
//  ex02
//
//  Created by Mansur Kakushkin on 2/13/25.
//

import SwiftUI

struct ContentView: View {
	@State var result : Float = 0
	@State var value : String = "0"
	
	var body: some View {
		GeometryReader { geometry in
			@State var width : CGFloat = geometry.size.width
			@State var height : CGFloat = geometry.size.height
			VStack {
				Header_name(width: $width, height: $height)
				Text_value(width: $width, height: $height, value: $value)
				Text_result(width: $width, height: $height, result: $result)
				Spacer()
				HStack {
					Button_number(width: $width, height: $height,numb: 7)
					Button_number(width: $width, height: $height,numb: 8)
					Button_number(width: $width, height: $height,numb: 9)
					Button_char(width: $width, height: $height,char: "C", color: Color.red)
					Button_char(width: $width, height: $height,char: "AC", color: Color.red)
				}
				HStack {
					Button_number(width: $width, height: $height,numb: 4)
					Button_number(width: $width, height: $height,numb: 5)
					Button_number(width: $width, height: $height,numb: 6)
					Button_char(width: $width, height: $height,char: "+", color: Color.white)
					Button_char(width: $width, height: $height,char: "-", color: Color.white)
				}
				HStack {
					Button_number(width: $width, height: $height,numb: 1)
					Button_number(width: $width, height: $height,numb: 2)
					Button_number(width: $width, height: $height,numb: 3)
					Button_char(width: $width, height: $height,char: "x", color: Color.white)
					Button_char(width: $width, height: $height,char: "/", color: Color.white)
				}
				HStack {
					Button_number(width: $width, height: $height,numb: 0)
					Button_char(width: $width, height: $height,char: ".", color: Color.blue)
					Button_char(width: $width, height: $height,char: "00", color: Color.blue)
					Button_char(width: $width, height: $height,char: "=", color: Color.white)
					Button_char(width: $width, height: $height,char: "", color: Color.white)
				}
				.preferredColorScheme(.dark)
			}
			.frame(width: width, height: height)
			
		}
	}
}

#Preview {
    ContentView()
}

struct Header_name: View {
	@Binding var width : CGFloat
	@Binding var height : CGFloat
	var body: some View {
		Text("Calculator")
			.padding()
			.foregroundStyle(Color.primary)
			.frame(width: width, height: height * 0.1)
			.background(.blue.tertiary)
			.clipShape(RoundedRectangle(cornerRadius: 30))
	}
}

struct Text_value: View {
	@Binding var width : CGFloat
	@Binding var height : CGFloat
	@Binding var value : String
	var body: some View {
		Text(value)
			.font(.largeTitle)
			.padding()
			.frame(width: width, height: height * 0.2, alignment: .trailing)
	}
}

struct Text_result: View {
	@Binding var width : CGFloat
	@Binding var height : CGFloat
	@Binding var result : Float
	var body: some View {
		if result == 0 {
			Text("0")
				.font(.largeTitle)
				.padding()
				.frame(width: width, height: height * 0.2, alignment: .trailing)
		}
		else {
			Text(String(result))
				.font(.largeTitle)
				.padding()
				.frame(width: width, height: height * 0.2, alignment: .trailing)
		}
	}
}

struct Button_number: View {
	@Binding var width : CGFloat
	@Binding var height : CGFloat
	@State var numb : Int
	var body: some View {
		Button(action: {
			print("button pressed:", String(numb))
		}, label: {
			Text(String(numb))
				.font(.largeTitle)
				.frame(width: width * 0.18, height: height * 0.10)
				.background(Color.gray.tertiary)
				.clipShape(RoundedRectangle(cornerRadius: 30))
		})
	}
}

struct Button_char: View {
	@Binding var width : CGFloat
	@Binding var height : CGFloat
	@State var char : String
	@State var color : Color
	var body: some View {
		if char == "" {
			Text("")
				.font(.largeTitle)
				.foregroundStyle(color)
				.frame(width: width * 0.18, height: height * 0.10)
				.background(Color.gray.tertiary)
				.clipShape(RoundedRectangle(cornerRadius: 30))
		}
		else {
			Button(action: {
				print("button pressed:", char)
			}, label: {
				Text(char)
					.font(.largeTitle)
					.foregroundStyle(color)
					.frame(width: width * 0.18, height: height * 0.10)
					.background(Color.gray.tertiary)
					.clipShape(RoundedRectangle(cornerRadius: 30))
			})
		}
	}
}


