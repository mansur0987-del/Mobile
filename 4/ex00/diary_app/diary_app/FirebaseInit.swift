//
//  FirebaseInit.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 2/26/25.
//

import Foundation
import Firebase
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		FirebaseApp.configure()
		
		return true
	}
	
	
}
