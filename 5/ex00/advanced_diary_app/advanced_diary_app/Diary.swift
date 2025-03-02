//
//  Diary.swift
//  advanced_diary_app
//
//  Created by Mansur Kakushkin on 3/1/25.
//

import SwiftUI

struct NotesListView : View {
	@State var notes : [Note] = []
	@Binding var userData : AuthDataResultModel?
	@Binding var IsShowAddNoteView : Bool
	@State var IsShowNoteView : Bool = false
	@State var idNoteShow: String?
	@State var smiles = GetSmiles()
	@State var IsCalendar : Bool = false
	@State var selectedDate : Date = Date()
	var body: some View {
		if IsCalendar == false {
			ScrollView {
				LastNotesView(notes: $notes, idNoteShow: $idNoteShow, IsShowNoteView: $IsShowNoteView)
				PercantFeelingView(smiles: $smiles, notes: $notes)
			}
			
		}
		else {
			ScrollView {
				CalendarView(selectedDate: $selectedDate)
				DateNotesView(notes: $notes, idNoteShow: $idNoteShow, IsShowNoteView: $IsShowNoteView, selectedDate: $selectedDate)
			}
		}
		HStack {
			Button {
				IsCalendar = false
			} label: {
				Image(systemName: "person.fill")
					.font(.system(size: 20))
					.foregroundStyle(.white.secondary)
					.padding(15)
					.background(.blue.secondary)
					.cornerRadius(30)
			}
			Button {
				IsCalendar = true
			} label: {
				Image(systemName: "calendar")
					.font(.system(size: 20))
					.foregroundStyle(.white.secondary)
					.padding(15)
					.background(.blue.secondary)
					.cornerRadius(30)
			}
		}
		.task {
			do {
				notes = try await FirebaseNote.shared.GetNotesList(email: userData!.email)
				smiles = SumPercant(smiles: smiles, notes: notes)
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
						smiles = SumPercant(smiles: smiles, notes: notes)
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
						smiles = SumPercant(smiles: smiles, notes: notes)
					}
					catch {
						print("Error: ", error)
					}
				}
			}
		}
	}
}

struct PercantFeelingView : View {
	@Binding var smiles : [Smile]
	@Binding var notes : [Note]
	var body: some View {
		VStack {
			Text("Total number of entries: " + String(notes.count))
			ForEach(smiles, id: \.self.id) { el in
				HStack {
					Image(el.imgName)
						.resizable()
						.frame(width: 30, height: 30)
						.padding(5)
						.background(el.color)
						.clipShape(RoundedRectangle(cornerRadius: 30))
					Spacer()
					Text(String(format: "%.2f", el.percant) + " %")
				}
			}
		}
		.font(.system(size: 20))
		.foregroundStyle(.white.secondary)
		.padding(18)
		.background(.gray.tertiary)
		.cornerRadius(30)
	}
}

struct LastNotesView : View {
	var smiles = GetSmiles()
	@Binding var notes : [Note]
	@Binding var idNoteShow: String?
	@Binding var IsShowNoteView: Bool
	var body: some View {
		ForEach(notes.prefix(2), id: \.self.id) { el in
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
			.background(.gray.tertiary)
			.clipShape(RoundedRectangle(cornerRadius: 30))
			.onTapGesture {
				idNoteShow = el.id
				IsShowNoteView.toggle()
			}
		}
	}
}


struct CalendarView: View {
	@Binding var selectedDate : Date
	
	var body: some View {
		DatePicker("Select date", selection: $selectedDate, displayedComponents: .date)
			.datePickerStyle(.graphical)
			.scaleEffect(0.5)
			.compositingGroup()
			.frame(maxHeight: 200)
			.background(.gray.tertiary)
			.clipShape(RoundedRectangle(cornerRadius: 30))
	}
}

struct DateNotesView : View {
	var smiles = GetSmiles()
	@Binding var notes : [Note]
	@Binding var idNoteShow: String?
	@Binding var IsShowNoteView: Bool
	@Binding var selectedDate : Date
	var body: some View {
		ForEach(notes, id: \.self.id) { el in
			if (el.created.string(format: "dd-MM-yyyy") == selectedDate.string(format: "dd-MM-yyyy")) {
				HStack {
					Image(smiles[el.feeling].imgName)
						.resizable()
						.frame(width: 30, height: 30)
						.background(smiles[el.feeling].color)
						.clipShape(RoundedRectangle(cornerRadius: 30))
					Text(el.title)
						.padding()
				}
				.background(.gray.tertiary)
				.clipShape(RoundedRectangle(cornerRadius: 30))
				.onTapGesture {
					idNoteShow = el.id
					IsShowNoteView.toggle()
				}
			}
		}
	}
}
