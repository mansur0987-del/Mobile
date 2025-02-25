//
//  FirebaseInit.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 2/26/25.
//

import Foundation


import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
				   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
	FirebaseApp.configure()

	return true
  }
	func application(_ app: UIApplication,
					 open url: URL,
					 options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
	  return GIDSignIn.sharedInstance.handle(url)
	}

}
