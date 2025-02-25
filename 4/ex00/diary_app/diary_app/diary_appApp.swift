//
//  diary_appApp.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 2/24/25.
//

import SwiftUI

@main
struct diary_appApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
