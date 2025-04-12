//
//  ChatroomView.swift
//  RealTimeChat
//
//  Created by Justin Wong on 4/12/25.
//

import SwiftUI

struct ChatroomView: View {
    @Environment(DatabaseManager.self) private var databaseManager

    var chatroom: RTCChatroom
    
    @State private var messageText = ""
    @State private var isSendingMessaage = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List(Array(chatroom.messages.enumerated()), id: \.offset) { _, message in
                    Text(message)
                }
                HStack {
                    TextField("Enter a message...", text: $messageText)
                        .textFieldStyle(.roundedBorder)
                    Button(action: {
                        Task {
                            isSendingMessaage = true
                            await databaseManager.sendChatroomMessage(messageText, chatroom: chatroom)
                            messageText = ""
                            isSendingMessaage = false
                        }
                        
                    }) {
                        if isSendingMessaage {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 28))
                        }
                    }
                    .disabled(isSendingMessaage)
                }
                .padding()
            }
            .navigationTitle(databaseManager.getChatroomFormattedParticipantsString(for: chatroom.participantIDs))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let chatroom = RTCChatroom(id: "1A5AE620-5DE5-43C6-B9A4-534052B7511E", participantIDs: [], messages: ["Hello!", "How are you!"])
    ChatroomView(chatroom: chatroom)
        .environment(DatabaseManager())
}
