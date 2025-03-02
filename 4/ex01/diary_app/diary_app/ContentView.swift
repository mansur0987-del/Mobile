//
//  ContentView.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 2/24/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
	
	@State private var IsMainView: Bool = false
	@State private var IsAuthView: Bool = false
	
	@State private var userData: AuthDataResultModel? = nil
	
    var body: some View {
        VStack {
			MainLoginView(IsMainView: $IsMainView, IsAuthView: $IsAuthView, userData: $userData)
        }
        .padding()
		.preferredColorScheme(.dark)
		.background()
		.fullScreenCover(isPresented: $IsAuthView) {
			AuthView(userData: $userData, IsAuthView: $IsAuthView, IsMainView: $IsMainView)
		}
		.fullScreenCover(isPresented: $IsMainView) {
			MainNotesList(IsMainView: $IsMainView, userData: $userData)
		}
		.onOpenURL { url in
			_ = Auth.auth().canHandle(url)
		}
    }
}

#Preview {
    ContentView()
}

struct MainLoginView : View {
	@Binding var IsMainView: Bool
	@Binding var IsAuthView: Bool
	@Binding var userData: AuthDataResultModel?
	var body: some View {
		Text("Welcome to your")
			.font(.system(size: 40))
			.foregroundStyle(.blue.secondary)
			.padding()
		Text("DIARY")
			.font(.system(size: 60))
			.foregroundStyle(.blue)
			.padding()
		Button {
			Task {
				do {
					userData = try await AuthenticationManager.shared.getAuthenticatedUser()
					IsMainView = true
					IsAuthView = false
				}
				catch {
					IsMainView = false
					IsAuthView = true
					print(error)
				}
				
			}
		} label: {
			Text("Login")
				.font(.system(size: 30))
				.foregroundStyle(.white.secondary)
				.padding(25)
				.background(.blue.secondary)
				.cornerRadius(30)
		}
	}
}

struct MainNotesList : View {
	@Binding var IsMainView : Bool
	@Binding var userData : AuthDataResultModel?
	@State var IsShowAddNoteView : Bool = false
	var body: some View {
		VStack {
			LogoutView(IsMainView: $IsMainView, userData: $userData)
			Text(userData?.email ?? "")
				.font(.system(size: 20))
				.padding(20)
				.foregroundStyle(.white.secondary)
				.background(.gray.tertiary)
				.clipShape(RoundedRectangle(cornerRadius: 30))
			NotesListView(userData: $userData, IsShowAddNoteView: $IsShowAddNoteView)
			Spacer()
			AddNoteView(IsShowAddNoteView: $IsShowAddNoteView, userData: $userData)
		}
		
	}
}

struct LogoutView :View {
	@StateObject private var viewModel = SettingsViewModel()
	@Binding var IsMainView : Bool
	@Binding var userData : AuthDataResultModel?
	var body: some View {
		Button {
			do {
				try viewModel.signOut()
				userData = nil
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
}

