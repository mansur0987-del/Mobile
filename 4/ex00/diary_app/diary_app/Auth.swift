//
//  Auth.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 2/27/25.
//

import Foundation
import UIKit
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift



struct GoogleSignInResultModel {
	let idToken: String
	let accessToken: String
	let name: String?
	let email: String?
}

struct GitHubSignInResultModel {
	let accessToken: String
	let email: String?
}


struct AuthDataResultModel {
	let uid: String
	let email: String?
	let photoUrl: String?
	let isAnonymous: Bool
	
	init(user: User) {
		self.uid = user.uid
		self.email = user.email
		self.photoUrl = user.photoURL?.absoluteString
		self.isAnonymous = user.isAnonymous
	}
}

final class Utilities {
	
	static let shared = Utilities()
	private init() {}
	
	@MainActor
	func topViewController(controller: UIViewController? = nil) -> UIViewController? {
		let controller = controller ?? UIApplication.shared
			.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }
			.first { $0.isKeyWindow }?
			.rootViewController
		
		if let navigationController = controller as? UINavigationController {
			return topViewController(controller: navigationController.visibleViewController)
		}
		if let tabController = controller as? UITabBarController {
			if let selected = tabController.selectedViewController {
				return topViewController(controller: selected)
			}
		}
		if let presented = controller?.presentedViewController {
			return topViewController(controller: presented)
		}
		return controller
	}
}

final class AuthenticationManager {
	
	static let shared = AuthenticationManager()
	private init() { }
	
	func getAuthenticatedUser() throws -> AuthDataResultModel {
		guard let user = Auth.auth().currentUser else {
			throw URLError(.badServerResponse)
		}
		
		return AuthDataResultModel(user: user)
	}
	
	func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
		let authDataResult = try await Auth.auth().signIn(with: credential)
		return AuthDataResultModel(user: authDataResult.user)
	}

	
	func signOut() throws {
		try Auth.auth().signOut()
	}
}

// MARK: SIGN IN SSO

extension AuthenticationManager {
	
	func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
		let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
		return try await signIn(credential: credential)
	}
}

final class SignInGoogleHelper {
	@MainActor
	func signIn() async throws -> GoogleSignInResultModel {
		guard let topVC = Utilities.shared.topViewController() else {
			throw URLError(.cannotFindHost)
		}
		
		let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
		
		guard let idToken = gidSignInResult.user.idToken?.tokenString else {
			throw URLError(.badServerResponse)
		}
		
		let accessToken = gidSignInResult.user.accessToken.tokenString
		let name = gidSignInResult.user.profile?.name
		let email = gidSignInResult.user.profile?.email

		let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, name: name, email: email)
		return tokens
	}
}


final class SignInGitHubHepler {
	
	@MainActor
	func signIn() async throws {
		let provider = OAuthProvider(providerID: "github.com")
		print("111")
		provider.scopes = ["read:user", "user:email"]
		print("222")
		do {
			// Получаем credential с помощью асинхронного вызова
			guard let credential = try await getCredentialWithAsync(provider: provider) else {
				print("Не удалось получить credential.")
				return
			}

			// Теперь выполняем вход в Firebase с использованием полученных учетных данных
			try await Auth.auth().signIn(with: credential)

			print("✅ Вход через GitHub выполнен!")
		} catch {
			print("Ошибка авторизации: \(error.localizedDescription)")
		}
//		await provider.getCredentialWith(nil) { credential, error in
//			print("333")
//			if let error = error {
//				print("Ошибка авторизации через GitHub: \(error.localizedDescription)")
//				return
//			}
//			print("444")
//			guard let credential = credential else {
//				print("Не удалось получить credential")
//				return
//			}
//			print("555")
//			// Авторизация в Firebase
//			Auth.auth().signIn(with: credential) { authResult, error in
//				if error != nil {
//					print("Ошибка входа в Firebase: \(error!.localizedDescription)")
//					return
//				}
//				print("Успешный вход! Пользователь: \(authResult?.user.displayName ?? "Без имени")")
//				
//				guard let oauthCredential = authResult?.credential else { return }
//			}
//		}
	}
	
	// Создаем обертку для асинхронного вызова
	func getCredentialWithAsync(provider: OAuthProvider) async throws -> AuthCredential? {
		return try await withCheckedThrowingContinuation { continuation in
			provider.getCredentialWith(nil) { credential, error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume(returning: credential)
				}
			}
		}
	}
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
	func signInGoogle() async throws {
		let helper = SignInGoogleHelper()
		let tokens = try await helper.signIn()
		let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
		print("authDataResult.email: ", authDataResult.email ?? "???" )
	}
	
	func signInGitHub() async throws {
		let helper = SignInGitHubHepler()
		try await helper.signIn()
	}
}

@MainActor
final class SettingsViewModel: ObservableObject {
	func signOut() throws {
		try AuthenticationManager.shared.signOut()
	}
}
