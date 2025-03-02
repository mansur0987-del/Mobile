//
//  CurrentNotesView.swift
//  advanced_diary_app
//
//  Created by Mansur Kakushkin on 3/2/25.
//

import SwiftUI
struct Smile {
	let id : Int
	let imgName: String
	let color: Color
	var percant: Double
}

func GetSmiles() -> [Smile] {
	return [
		Smile(id: 0, imgName: "crying", color: Color.red, percant: 0),
		Smile(id: 1, imgName: "sad-face", color: Color.blue, percant: 0),
		Smile(id: 2, imgName: "neutral-face", color: Color.gray, percant: 0),
		Smile(id: 3, imgName: "happiness", color: Color.orange, percant: 0),
		Smile(id: 4, imgName: "happy", color: Color.yellow, percant: 0)
	]
}

func SumPercant(smiles : [Smile], notes: [Note]) -> [Smile] {
	var NewSmiles : [Smile] = []
	var i = 0
	if notes.count != 0 {
		while (i < smiles.count) {
			let feelSum = Double(notes.filter({ note in note.feeling == smiles[i].id }).count)
			let percant : Double = feelSum / Double(notes.count) * 100
			print("percant: ", percant)
			let newSmile = Smile(id: smiles[i].id,
								 imgName: smiles[i].imgName,
								 color: smiles[i].color,
								 percant: percant)
			NewSmiles.append(newSmile)
			i = i + 1
		}
		return NewSmiles
	}
	return smiles
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
