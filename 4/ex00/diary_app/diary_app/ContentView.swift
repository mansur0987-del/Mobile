//
//  ContentView.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 2/24/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
	@StateObject private var viewModel = SettingsViewModel()
	@State private var IsMainView: Bool = false
	@State private var IsAuthView: Bool = false
	
    var body: some View {
        VStack {
			Text("Welcome to your")
				.font(.system(size: 40))
				.padding()
			Text("Diary")
				.font(.system(size: 50))
				.padding()
			Button {
				Task {
					let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
					if authUser == nil {
						IsMainView = false
						IsAuthView = true
					}
					else {
						IsMainView = true
						IsAuthView = false
					}
					print("IsMainView: ", IsMainView)
					print("IsAuthView: ", IsAuthView)
				}
			} label: {
				Text("Login")
					.padding()
					.background(.gray.tertiary)
					.cornerRadius(30)
			}
			
        }
        .padding()
		.preferredColorScheme(.dark)
		.background()
		.fullScreenCover(isPresented: $IsAuthView) {
			AuthView(IsAuthView: $IsAuthView, IsMainView: $IsMainView)
		}
		.fullScreenCover(isPresented: $IsMainView) {
			Button {
				do {
					try viewModel.signOut()
					IsMainView = false
					print("Logout")
				} catch {
					print(error)
				}
			} label: {
				Text("Logout")
					.padding()
					.background(.gray.tertiary)
					.cornerRadius(30)
			}
		}
		.onOpenURL { url in
			_ = Auth.auth().canHandle(url)
		}
    }
}

#Preview {
    ContentView()
}
