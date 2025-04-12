//
//  Model.swift
//  RealTimeChat
//
//  Created by Justin Wong on 4/12/25.
//

import FirebaseFirestore
import Foundation

struct RTCUser: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var chatRoomIDs: [String]
}

struct RTCChatroom: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var participantIDs: [String]
    var messages: [String]
    
    func getMostRecentMessage() -> String {
        return messages.last ?? "No Messages Yet"
    }
}
