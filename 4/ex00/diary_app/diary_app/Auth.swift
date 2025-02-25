//
//  Auth.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 2/26/25.
//

import Foundation
import Firebase
import FirebaseAuth


class AuthViewModel: ObservableObject {
	@Published var user: User?
	
	init() {
		self.user = Auth.auth().currentUser
	}
	
	
	func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
		Auth.auth().signIn(withEmail: email, password: password) { result, error in
			if let user = result?.user {
				DispatchQueue.main.async {
					self.user = user
				}
			}
			completion(error)
		}
	}

	func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
		Auth.auth().createUser(withEmail: email, password: password) { result, error in
			if let user = result?.user {
				DispatchQueue.main.async {
					self.user = user
				}
			}
			completion(error)
		}
	}

	func signOut() {
		try? Auth.auth().signOut()
		DispatchQueue.main.async {
			self.user = nil
		}
	}
}
