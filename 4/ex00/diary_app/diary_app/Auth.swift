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
	let uid: String
}


struct AuthDataResultModel {
	let uid: String
	let email: String?
	let photoUrl: String?
	let isAnonymous: Bool
	
	init(user: User) {
		self.uid = user.uid
		self.email = user.email != nil ? user.email : user.providerData.first as? String
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
	
	func getAuthenticatedUser() async throws -> AuthDataResultModel {
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
	func signIn() async throws -> AuthDataResultModel {
		let provider = OAuthProvider(providerID: "github.com")
		provider.scopes = ["read:user", "user:email"]
		do {
			// Получаем credential с помощью асинхронного вызова
			let credential = try await getCredentialWithAsync(provider: provider)
			// Теперь выполняем вход в Firebase с использованием полученных учетных данных
			if credential == nil {
				throw URLError(.badServerResponse)
			}
			let authDataResult = try await Auth.auth().signIn(with: credential!)
			print (authDataResult.user)
			if authDataResult.additionalUserInfo != nil {
				print (authDataResult.additionalUserInfo!.username ?? "default value")
				print (authDataResult.additionalUserInfo!.profile ?? "default value")
			}
			
			print(authDataResult.user.providerData)
			
			
			return AuthDataResultModel(user: authDataResult.user)
		} catch {
			throw error
		}
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
	func signInGoogle() async throws -> AuthDataResultModel {
		let helper = SignInGoogleHelper()
		do {
			let tokens = try await helper.signIn()
			return try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
		}
		catch {
			throw error
		}
	}
	
	func signInGitHub() async throws -> AuthDataResultModel {
		let helper = SignInGitHubHepler()
		do {
			return try await helper.signIn()
		}
		catch {
			throw error
		}
		
	}
}

@MainActor
final class SettingsViewModel: ObservableObject {
	func signOut() throws {
		try AuthenticationManager.shared.signOut()
	}
}
