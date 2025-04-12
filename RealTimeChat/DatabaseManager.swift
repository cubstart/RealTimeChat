//
//  DatabaseManager.swift
//  RealTimeChat
//
//  Created by Justin Wong on 4/10/25.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Observation
import SwiftUI

@MainActor
@Observable
class DatabaseManager {
    var users: [RTCUser] = []
    var chatrooms: [RTCChatroom] = []
    
    var isAuthChanging = false
    var currentUser: RTCUser?
    
    @ObservationIgnored
    private var currentUserListener: ListenerRegistration?
    @ObservationIgnored
    private var chatroomsListener: ListenerRegistration?
    
    @ObservationIgnored
    private let firebaseAuth = Auth.auth()
    @ObservationIgnored
    private let db = Firestore.firestore()
    
    init() {
        listenToAuthChangesForCurrentUser()
    }
    
    
    // MARK: - Authentication
    
    func listenToAuthChangesForCurrentUser() {
        isAuthChanging = true
        _ = firebaseAuth.addStateDidChangeListener { auth, user in
            guard let userUID = user?.uid else {
                self.currentUser = nil
                self.isAuthChanging = false
                self.currentUserListener?.remove()
                self.chatroomsListener?.remove()
                return
            }
        
            Task {
                self.listenToChangesToCurrentUser(withUID: userUID)
                await self.fetchAllUsers()
                self.isAuthChanging = false
            }
        }
    }
    
    func createNewUser(withEmail email: String, withPassword password: String, name: String) {
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        
        firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
            if let error {
                // Handle the err
                print(error)
                return
            }
            
            guard let authResult else {
                // Handle the error
                return
            }
            
            Task {
                await self.createUserData(withNewUID: authResult.user.uid, name: name)
            }
        }
    }
    
    func signInUser(withEmail email: String, withPassword password: String) {
        firebaseAuth.signIn(withEmail: email, password: password) { authResult, error in
            if let error {
                // Handle error
                print(error)
                return
            }
        }
    }
    
    func signOut() {
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    
    // MARK: - User
    
    func listenToChangesToCurrentUser(withUID uid: String) {
        currentUserListener = db.collection(Constants.usersCollectionName)
                            .document(uid)
                            .addSnapshotListener { snapshot, error in
            do {
                print("Changes to current user")
                self.currentUser = try snapshot?.data(as: RTCUser.self)
                self.listenToUserChatrooms()
            } catch {
                print("Error getting current user")
            }
        }
    }
    
    private func createUserData(withNewUID uid: String, name: String) async {
        do {
            try await db.collection(Constants.usersCollectionName).document(uid).setData([
            "name": name,
            "chatRoomIDs": []
          ])
          print("Document successfully written!")
        } catch {
          print("Error writing document: \(error)")
        }
    }
    
    func fetchAllUsers() async {
        do {
            let querySnapshot = try await db.collection(Constants.usersCollectionName).getDocuments()
            users = try querySnapshot.documents.compactMap { document in
                try document.data(as: RTCUser.self)
            }
        } catch {
            print("Error fetching all users: \(error)")
        }
    }
    
    func isCurrentUser(_ user: RTCUser) -> Bool {
        guard let currentUser else {
            return false
        }
        return user.id == currentUser.id
    }
    
    
    // MARK: - Chatroom
    
    func listenToUserChatrooms() {
        guard let currentUser, !currentUser.chatRoomIDs.isEmpty else {
            return
        }
        chatroomsListener = db.collection(Constants.chatroomsCollectionName)
                            .whereField(FieldPath.documentID(), in: currentUser.chatRoomIDs)
                            .addSnapshotListener { snapshot, error in
            if let error {
                print("Error listening for chatroom updates: \(error)")
                return
            }
            
            guard let snapshot else {
                return
            }
            
            print("Chatrooms Collection Updated")
            
            do {
                self.chatrooms = try snapshot.documents.compactMap { document in
                    try document.data(as: RTCChatroom.self)
                }
            } catch {
                print("Error converting data into chatrooms")
            }
        }
    }
    
    func createNewChatroom(with users: [RTCUser]) async {
        guard let currentUser else {
            return
        }
        
        let usersWithCurrentUser = users + [currentUser]
        
        let newChatroomID = UUID().uuidString
        do {
            // Create new chatroom in Constants.chatroomsCollectionName collection
            try await db.collection(Constants.chatroomsCollectionName).document(newChatroomID).setData([
                "participantIDs": usersWithCurrentUser.map { $0.id },
                "messages": []
            ])
            
            // Update "chatRoomIDs" property for all users in this new chatroom
            for user in usersWithCurrentUser {
                if let userID = user.id {
                    try await db.collection(Constants.usersCollectionName).document(userID).updateData([
                        "chatRoomIDs": FieldValue.arrayUnion([newChatroomID])
                    ])
                }
            }
          print("Document successfully written!")
        } catch {
          print("Error writing document: \(error)")
        }
    }
    
    func deleteChatroom(_ chatroom: RTCChatroom) async {
        guard let chatroomID = chatroom.id else {
            return
        }
        
        do {
            try await db.collection(Constants.chatroomsCollectionName).document(chatroomID).delete()
            
            // Delete chatroom ids from "chatroomIDs" property of users
            for chatroomParticipantID in chatroom.participantIDs {
                try await db.collection(Constants.usersCollectionName).document(chatroomParticipantID).updateData([
                    "chatRoomIDs": FieldValue.arrayRemove([chatroomID])
                ])
            }
            print("Document successfully removed!")
        } catch {
            print("Error removing document: \(error)")
        }
    }
    
    func sendChatroomMessage(_ message: String, chatroom: RTCChatroom) async {
        do {
            guard let chatroomID = chatroom.id else {
                return
            }
            
            try await db.collection(Constants.chatroomsCollectionName).document(chatroomID).updateData([
                "messages": chatroom.messages + [message]
            ])
          print("Document successfully updated")
        } catch {
          print("Error updating document: \(error)")
        }
    }
    
    func getChatroomFormattedParticipantsString(for participantIDs: [String]) -> String {
        return users.filter { participantIDs.contains($0.id ?? "") }.map { $0.name }.joined(separator: ", ")
    }
}
