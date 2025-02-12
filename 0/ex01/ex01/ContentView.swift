//
//  ContentView.swift
//  ex01
//
//  Created by Mansur Kakushkin on 2/13/25.
//

import SwiftUI

struct ContentView: View {
	@State var print_text : String = "A simple text"
    var body: some View {
		VStack {
			Text(print_text)
				.foregroundStyle(Color.primary)
				.padding(10)
				.background(Color.gray)
				.clipShape(RoundedRectangle(cornerRadius: 20))
			Button {
				print("Button pressed")
				print_text = print_text == "Hello World!" ? "A simple text" : "Hello World!"
			} label: {
				Text("Click me")
			}
			.foregroundStyle(Color.primary)
			.padding(10)
			.background(.blue)
			.clipShape(RoundedRectangle(cornerRadius: 20))
		}
		.preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
		.padding()
    }
}

#Preview {
    ContentView()
}
