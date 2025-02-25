//
//  ContentView.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 2/24/25.
//

import SwiftUI

struct ContentView: View {
	@State var IsLoginButton : Bool = false
    var body: some View {
        VStack {
			Text("Welcome to your")
				.font(.system(size: 40))
				.padding()
			Text("Diary")
				.font(.system(size: 50))
				.padding()
			Button(action: {
				IsLoginButton.toggle()
			}, label: {
				Text("Login")
					.padding()
					.background(.gray.tertiary)
					.cornerRadius(30)
			})
			.padding()
        }
        .padding()
		.fullScreenCover(isPresented: $IsLoginButton, content: {
			LoginSheet(IsLoginButton : $IsLoginButton)
		})
		.preferredColorScheme(.dark)
		.background()
    }
}

#Preview {
    ContentView()
}

struct LoginSheet: View {
	@Binding var IsLoginButton : Bool
	var body: some View {
		VStack{
			HStack{
				Button(action: {
					IsLoginButton.toggle()
				}, label: {
					Text("Cancel")
						.padding()
						.background(.red.tertiary)
						.cornerRadius(30)
				})
				.padding()
				Spacer()
			}
			Spacer()
		}
	}
}
