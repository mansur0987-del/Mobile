//
//  db.swift
//  diary_app
//
//  Created by Mansur Kakushkin on 2/28/25.
//

import Foundation
import FirebaseFirestore

struct Note: Codable {
	@DocumentID var id: String?  // ID документа (авто)
	var ownerId: String
	var email: String
	var created: Date
	var title: String
	var feeling: Int
	var content: String
}


struct FeelingInterface  {
	var feelingId : Int
	var FeelingStr : String
}


final class FirebaseNote {
	let db = Firestore.firestore()
	var notes : [Note] = []
	
	static let shared = FirebaseNote()
	private init() { }
	
	func GetNotesList(email: String) async throws -> [Note] {
		do {
			let snapshot = try await db.collection("notes")
				.whereField("email", isEqualTo: email)
				.order(by: "created", descending: true)
				.getDocuments()
			let notes: [Note] = snapshot.documents.compactMap { doc in
				return try? doc.data(as: Note.self)
			}
			return notes
		}
		catch {
			throw error
		}
	}
	
	func AddNote(note: Note) async throws {
		do {
			let ref = try await db.collection("notes").addDocument(data: [
				"ownerId": note.ownerId,
				"email": note.email,
				"created": note.created,
				"title": note.title,
				"feeling": note.feeling,
				"content": note.content
			  ])
			print ("note: ", note)
			print("Document added with ID: \(ref.documentID)")
		}
		catch {
			throw error
		}
	}
	
	func DeleteNote(noteId: String) async throws {
		do {
			try await db.collection("notes").document(noteId).delete()
			print("Document with ID: \(noteId) deleted")
		}
		catch {
			throw error
		}
	}
}


extension Date {
	func string(format: String) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter.string(from: self)
	}
}
