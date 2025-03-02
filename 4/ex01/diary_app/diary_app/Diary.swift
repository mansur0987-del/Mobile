//
//  Diary.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 3/1/25.
//

import SwiftUI

struct Smile {
	let id : Int
	let imgName: String
	let color: Color
}

func GetSmiles() -> [Smile] {
	return [
		Smile(id: 0, imgName: "crying", color: Color.red),
		Smile(id: 1, imgName: "sad-face", color: Color.blue),
		Smile(id: 2, imgName: "neutral-face", color: Color.gray),
		Smile(id: 3, imgName: "happiness", color: Color.orange),
		Smile(id: 4, imgName: "happy", color: Color.yellow)
	]
}


struct NotesListView : View {
	@State var notes : [Note] = []
	@Binding var userData : AuthDataResultModel?
	@Binding var IsShowAddNoteView : Bool
	@State var IsShowNoteView : Bool = false
	@State var idNoteShow: String?
	var smiles = GetSmiles()
	var body: some View {
		ScrollView {
			ForEach(notes, id: \.self.id) { el in
				HStack {
					Text(el.created.string(format: "dd-MM-yyyy HH:mm"))
						.padding()
					Image(smiles[el.feeling].imgName)
						.resizable()
						.frame(width: 30, height: 30)
						.background(smiles[el.feeling].color)
						.clipShape(RoundedRectangle(cornerRadius: 30))
					Text(el.title)
						.padding()
				}
				.padding()
				.background(.gray.tertiary)
				.clipShape(RoundedRectangle(cornerRadius: 30))
				.onTapGesture {
					idNoteShow = el.id
					IsShowNoteView.toggle()
				}
			}
		}
		.task {
			do {
				notes = try await FirebaseNote.shared.GetNotesList(email: userData!.email)
			}
			catch {
				print("Error: ", error)
			}
		}
		.onChange(of: IsShowAddNoteView) { oldValue, newValue in
			if newValue == false {
				Task {
					do {
						notes = try await FirebaseNote.shared.GetNotesList(email: userData!.email)
					}
					catch {
						print("Error: ", error)
					}
				}
			}
		}
		.sheet(isPresented: $IsShowNoteView) {
			SheetNoteView(note: notes.first(where: { el in
				el.id == idNoteShow!
			})!, IsShowNoteView: $IsShowNoteView)
		}
		.onChange(of: IsShowNoteView) { oldValue, newValue in
			if newValue == false {
				Task {
					do {
						notes = try await FirebaseNote.shared.GetNotesList(email: userData!.email)
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
	@Binding var IsShowAddNoteView : Bool
	@Binding var userData : AuthDataResultModel?
	var body: some View {
		VStack {
			Button {
				IsShowAddNoteView.toggle()
			} label: {
				Text("New diary entry")
					.font(.system(size: 20))
					.foregroundStyle(.white.secondary)
					.padding(18)
					.background(.blue.secondary)
					.cornerRadius(30)
			}
		}
		.sheet(isPresented: $IsShowAddNoteView) {
			AddNoteFieldView(IsShowAddNoteView: $IsShowAddNoteView, userData: $userData)
		}
	}
}

struct AddNoteFieldView : View {
	@Binding var IsShowAddNoteView : Bool
	@State var title : String = ""
	@State var content : String = ""
	@State var feeling : Int = 3
	@Binding var userData : AuthDataResultModel?
	var body: some View {
		VStack{
			TextField("Title", text: $title)
				.font(.system(size: 20))
				.foregroundStyle(.white)
				.padding()
				.background(.gray.tertiary)
				.clipShape(RoundedRectangle(cornerRadius: 50))
			ChoiceFeelingView(feeling: $feeling)
				.padding()
				.background(.gray.tertiary)
				.clipShape(RoundedRectangle(cornerRadius: 50))
			TextField("Content", text: $content)
				.font(.system(size: 15))
				.foregroundStyle(.white)
				.padding()
				.background(.gray.tertiary)
				.clipShape(RoundedRectangle(cornerRadius: 50))
			HStack {
				Button {
					Task {
						do {
							print("userData!:", userData!)
							try await FirebaseNote.shared.AddNote(note: Note(ownerId: userData!.uid, email: userData!.email, created: Date(), title: title, feeling: feeling, content: content))
							IsShowAddNoteView.toggle()
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
						.clipShape(RoundedRectangle(cornerRadius: 30))
				}
				.disabled((title == "" ||  content == "") ? true : false)
				.padding()
				Button {
					IsShowAddNoteView.toggle()
				} label: {
					Text("Cancel")
						.font(.system(size: 20))
						.foregroundStyle(.white.secondary)
						.padding(18)
						.background(.red.secondary)
						.clipShape(RoundedRectangle(cornerRadius: 30))
				}
			}
			
			
			
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
						.frame(width: 30, height: 30)
						.padding(5)
						.background(el.id == feeling ? .white : el.color)
						.clipShape(RoundedRectangle(cornerRadius: 50))
				}
			}
		}
	}
}

struct SheetNoteView : View {
	var smiles = GetSmiles()
	var note : Note
	@Binding var IsShowNoteView : Bool
	var body: some View {
		VStack {
			ScrollView {
				Text(note.created.string(format: "dd-MM-yyyy HH:mm"))
					.padding()
				Image(smiles[note.feeling].imgName)
					.resizable()
					.frame(width: 30, height: 30)
					.background(smiles[note.feeling].color)
					.clipShape(RoundedRectangle(cornerRadius: 30))
				Text(note.title)
					.padding()
					.font(.system(size: 20))
				Text(note.content)
					.padding()
					.font(.system(size: 15))
			}
			Spacer()
			HStack {
				Button {
					Task {
						do {
							try await FirebaseNote.shared.DeleteNote(noteId: note.id!)
							IsShowNoteView.toggle()
						}
						catch {
							print(error)
						}
					}
				} label: {
					Text("Delete")
						.font(.system(size: 20))
						.foregroundStyle(.white.secondary)
						.padding(18)
						.background(.red.secondary)
						.clipShape(RoundedRectangle(cornerRadius: 30))
				}
				.padding()
				
				Button {
					IsShowNoteView.toggle()
				} label: {
					Text("Close")
						.font(.system(size: 20))
						.foregroundStyle(.white.secondary)
						.padding(18)
						.background(.blue.secondary)
						.clipShape(RoundedRectangle(cornerRadius: 30))
				}
				.padding()
			}
		}
	}
}
