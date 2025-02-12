//
//  ContentView.swift
//  ex00
//
//  Created by Mansur Kakushkin on 2/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
			Text("A simple text")
				.foregroundStyle(Color.primary)
				.padding(10)
				.background(Color.gray)
				.clipShape(RoundedRectangle(cornerRadius: 20))
			Button {
				print("Button pressed")
				
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
