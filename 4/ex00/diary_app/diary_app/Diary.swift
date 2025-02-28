//
//  Diary.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 3/1/25.
//

import SwiftUI

struct Smile {
	var id : Int
	var imgName: String
}

func GetSmiles() -> [Smile] {
	return [
		Smile(id: 1, imgName: "crying"),
		Smile(id: 2, imgName: "sad-face"),
		Smile(id: 3, imgName: "neutral-face"),
		Smile(id: 4, imgName: "happiness"),
		Smile(id: 5, imgName: "happy")
	]
}


struct NotesListView : View {
	@State var notes : [Note] = []
	@Binding var userData : AuthDataResultModel?
	@Binding var IsShowNoteView : Bool
	var smiles = GetSmiles()
	var body: some View {
		ScrollView {
			ForEach(notes, id: \.self.id) { el in
				HStack {
					Text(el.created.string(format: "dd-MM-yyyy HH:mm")).padding()
					Image(smiles[el.feeling].imgName)
						.resizable()
						.frame(width: 20, height: 20)
						.background(.white)
					Text(el.title)
				}
			}
		}
		.task {
			do {
				notes = try await FirebaseNote.shared.GetNotesList(ownerId: userData!.uid)
			}
			catch {
				print("Error: ", error)
			}
		}
		.onChange(of: IsShowNoteView) { oldValue, newValue in
			if newValue == false {
				Task {
					do {
						notes = try await FirebaseNote.shared.GetNotesList(ownerId: userData!.uid)
					}
					catch {
						print("Error: ", error)
					}
				}
			}
		}
	}
}

struct AddNoteView : View {
	@Binding var IsShowNoteView : Bool
	@Binding var userData : AuthDataResultModel?
	var body: some View {
		VStack {
			Button {
				IsShowNoteView.toggle()
			} label: {
				Text("New diary entry")
					.font(.system(size: 20))
					.foregroundStyle(.white.secondary)
					.padding(18)
					.background(.blue.secondary)
					.cornerRadius(30)
			}
		}
		.sheet(isPresented: $IsShowNoteView) {
			AddNoteFieldView(IsShowNoteView: $IsShowNoteView, userData: $userData)
		}
	}
}

struct AddNoteFieldView : View {
	@Binding var IsShowNoteView : Bool
	@State var title : String = ""
	@State var content : String = ""
	@State var feeling : Int = 3
	@Binding var userData : AuthDataResultModel?
	var body: some View {
		VStack{
			TextField("Title", text: $title)
				.foregroundStyle(.blue.secondary)
				.background(.white.secondary)
				.padding()
			ChoiceFeelingView(feeling: $feeling)
				.foregroundStyle(.blue.secondary)
				.background(.white.secondary)
				.padding()
			TextField("Content", text: $content)
				.foregroundStyle(.blue.secondary)
				.background(.white.secondary)
				.padding()
			Button {
				Task {
					do {
						try await FirebaseNote.shared.AddNote(note: Note(ownerId: userData!.uid, email: userData!.email!, created: Date(), title: title, feeling: feeling, content: content))
						IsShowNoteView.toggle()
					}
					catch {
						print("Error: ", error)
					}
				}
				
			} label: {
				Text("Add")
					.font(.system(size: 20))
					.foregroundStyle(.white.secondary)
					.padding(18)
					.background(.blue.secondary)
					.cornerRadius(30)
			}
			.disabled((title == "" ||  content == "") ? true : false)
			
		}
	}
}

struct ChoiceFeelingView : View {
	@Binding var feeling : Int
	var smile: [Smile] = GetSmiles()
	var body: some View {
		HStack {
			ForEach(smile, id: \.self.id) { el in
				Button {
					feeling = el.id
				} label: {
					Image(el.imgName)
						.resizable()
						.frame(width: 20, height: 20)
						.background(el.id == feeling ? .blue : .white)
				}
				.padding()
			}
		}
	}
}
