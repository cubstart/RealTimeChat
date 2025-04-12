//
//  ChatroomRowView.swift
//  RealTimeChat
//
//  Created by Justin Wong on 4/12/25.
//

import SwiftUI

struct ChatroomRowView: View {
    @Environment(DatabaseManager.self) private var databaseManager
    
    var chatroom: RTCChatroom
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(databaseManager.getChatroomFormattedParticipantsString(for: chatroom.participantIDs))
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer()
            Text(chatroom.getMostRecentMessage())
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            Spacer()
        }
        .frame(height: 50)
    }
}

#Preview {
    let chatroom = RTCChatroom(participantIDs: ["7nqoUyXIApbQAaBxwx6Pb9pzMjw1", "QuZIQIKoLwX1o2qlStPyELqkfe63"], messages: [])
    ChatroomRowView(chatroom: chatroom)
        .environment(DatabaseManager())
}
