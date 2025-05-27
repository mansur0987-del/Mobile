//
//  AuthView.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 2/27/25.
//

import SwiftUI

struct AuthView : View {
	@StateObject private var viewModel = AuthenticationViewModel()
	@Binding var userData : AuthDataResultModel?
	@Binding var IsAuthView: Bool
	@Binding var IsMainView: Bool
	var body: some View {
		VStack {
			Button(action: {
				Task {
					do {
						userData = try await viewModel.signInGoogle()
						IsAuthView = false
						IsMainView = true
					} catch {
						print(error)
					}
				}
			}, label: {
				HStack {
					Image("google_image")
					Text("Continue with Google")
				}
				.font(.system(size: 20))
				.foregroundStyle(.white.secondary)
				.padding()
				.background(.blue.secondary)
				.cornerRadius(30)
			})
			.padding()
			Button(action: {
				Task {
					do {
						userData = try await viewModel.signInGitHub()
						print("userData:", userData!)
						IsAuthView = false
						IsMainView = true
					} catch {
						print(error)
					}
				}
			}, label: {
				HStack {
					Image("github_image")
					Text("Continue with GitHub")
				}
				.font(.system(size: 20))
				.foregroundStyle(.white.secondary)
				.padding()
				.background(.blue.secondary)
				.cornerRadius(30)
			})
			.padding()
		}
	}
}
