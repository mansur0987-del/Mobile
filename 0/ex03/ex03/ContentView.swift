//
//  ContentView.swift
//  ex03
//
//  Created by Mansur Kakushkin on 2/14/25.
//

import SwiftUI
import Foundation

struct ContentView: View {
	@State var result : String = "0"
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
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "7", color: Color.blue)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "8", color: Color.blue)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "9", color: Color.blue)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "C", color: Color.red)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "AC", color: Color.red)
				}
				HStack {
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "4", color: Color.blue)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "5", color: Color.blue)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "6", color: Color.blue)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "+", color: Color.white)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "-", color: Color.white)
				}
				HStack {
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "1", color: Color.blue)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "2", color: Color.blue)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "3", color: Color.blue)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "x", color: Color.white)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "/", color: Color.white)
				}
				HStack {
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "0", color: Color.blue)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: ".", color: Color.blue)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "00", color: Color.blue)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "=", color: Color.white)
					Button_char(width: $width, height: $height,value: $value, result: $result, char: "", color: Color.white)
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
	@Binding var result : String
	var body: some View {
		Text(result)
			.font(.largeTitle)
			.padding()
			.frame(width: width, height: height * 0.2, alignment: .trailing)
	}
}

struct Button_char: View {
	@Binding var width : CGFloat
	@Binding var height : CGFloat
	@Binding var value : String
	@Binding var result : String
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
			Button(action:  {
				if char == "=" {
					if [".", "+", "-", "*", "/"].contains(value.last){
					}
					else {
						let elements = parseExpression(value)
						var check_result = checkExpression(elements)
						
						if ["Infinity", "-Infinity"].contains(check_result) {
							result = check_result
							value = "0"
							return
						}
						
						let exp = NSExpression(format: check_result)
						if let tmp_result = exp.expressionValue(with: nil, context: nil) as? NSNumber {
							result = tmp_result.stringValue
						}
						value = "0"
					}
				}
				else if char == "AC" {
					value = "0"
					result = "0"
				}
				else if char == "C" {
					if value.count == 1 {
						value = "0"
					}
					else {
						value = String(value.dropLast())
					}
				}
				else if value.count == 1, value.last == "0" {
					if ["x", "/", "00", "+" ].contains(char) {
					}
					else if char == "." {
						value = value + char
					}
					else {
						value = char
					}
				}
				else {
					if ["*", "/", "+", ".", "-" ].contains(value.last), ["x", "/", "+", "." ].contains(char) {
					}
					else if value.last == ".", char == "-" {
						
					}
					else if char == "x"{
						value = value + "*"
					}
					else {
						value = value + char
					}
					
				}
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


func parseExpression(_ expression: String) -> [String] {
	let pattern = "[0-9.]+|[+\\-*/]"
	let regex = try! NSRegularExpression(pattern: pattern)
	let matches = regex.matches(in: expression, range: NSRange(expression.startIndex..., in: expression))
	
	return matches.map { match in
		String(expression[Range(match.range, in: expression)!])
	}
}

func checkExpression(_ elements: [String]) -> String {
	var i = 0
	var new_exp = ""
	while (i < elements.count){
		if elements[i] == "/" {
			if Double(elements[i + 1]) == 0 {
				return "Infinity"
			}
			else if elements[i + 1] == "-", Double(elements[i + 2]) == 0 {
				return "-Infinity"
			}
		}
		if elements[i].last!.isNumber {
			new_exp = new_exp + String(Double(elements[i])!)
		}
		else{
			new_exp = new_exp + elements[i]
		}
		i += 1
	}
	return new_exp
}
