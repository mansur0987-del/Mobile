//
//  ContentView.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 2/24/25.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct ContentView: View {
	@State private var isLoading = false
	private var contextProvider = ContextProvider()
	
    var body: some View {
        VStack {
			Text("Welcome to your")
				.font(.system(size: 40))
				.padding()
			Text("Diary")
				.font(.system(size: 50))
				.padding()
			Button(action: {
				signInWithWebRedirect()
			}, label: {
				Text("Login")
					.padding()
					.background(.gray.tertiary)
					.cornerRadius(30)
			})
			.padding()
        }
        .padding()
//		.fullScreenCover(isPresented: $IsLoginButton, content: {
//			LoginSheet(IsLoginButton : $IsLoginButton)
//		})
		.preferredColorScheme(.dark)
		.background()
    }
	func signInWithWebRedirect() {
		guard let url = URL(string: "https://diary-app-b0f08.web.app/__/auth/handler") else { return }
		isLoading = true
		
		let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "com.googleusercontent.apps.1067011176693-a8t5v428tq6p4e668fsjl9smhs1nuisu", completionHandler: { callbackURL, error in
			isLoading = false
			if let error = error {
				print("Ошибка авторизации: \(error.localizedDescription)")
				return
			}
			print("Успешная авторизация: \(callbackURL?.absoluteString ?? "")")
		})
		session.presentationContextProvider = contextProvider // Используем сохраненный объект
		session.start()

	}
}

#Preview {
    ContentView()
}

class ContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
	func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
			guard let windowScene = UIApplication.shared.connectedScenes
					.compactMap({ $0 as? UIWindowScene })
					.first,
				  let window = windowScene.windows.first else {
				fatalError("Ошибка: Не удалось найти активное окно")
			}
			return window
		}
}

