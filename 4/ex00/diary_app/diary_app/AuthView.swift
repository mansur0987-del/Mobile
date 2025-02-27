//
//  AuthView.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 2/27/25.
//

import SwiftUI

struct AuthView : View {
	@StateObject private var viewModel = AuthenticationViewModel()
	@Binding var IsAuthView: Bool
	@Binding var IsMainView: Bool
	var body: some View {
		VStack {
			Button(action: {
				Task {
					do {
						try await viewModel.signInGoogle()
						IsAuthView = false
						IsMainView = true
						print("GOOGLE AUTH!")
					} catch {
						print(error)
					}
				}
			}, label: {
				Text("Google Auth")
					.padding()
					.background(.gray.tertiary)
					.cornerRadius(30)
			})
			.padding()
			Button(action: {
				Task {
					do {
						try await viewModel.signInGitHub()
						IsAuthView = false
						IsMainView = true
						print("GIT HUB AUTH!")
					} catch {
						print(error)
					}
				}
			}, label: {
				Text("Github Auth")
					.padding()
					.background(.gray.tertiary)
					.cornerRadius(30)
			})
			.padding()
		}
	}
}
