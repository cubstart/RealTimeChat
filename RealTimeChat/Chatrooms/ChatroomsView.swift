//
//  ChatroomsView.swift
//  RealTimeChat
//
//  Created by Justin Wong on 4/10/25.
//

import SwiftUI

struct ChatroomsView: View {
    @Environment(DatabaseManager.self) private var databaseManager
    
    @State private var showCreateChatroomView = false
    
    var body: some View {
        NavigationStack {
            Group {
                if databaseManager.chatrooms.isEmpty {
                    RTCEmptyView(message: "No Chatrooms Available")
                } else {
                    List{
                        ForEach(databaseManager.chatrooms) { chatroom in
                            NavigationLink {
                                ChatroomView(chatroom: chatroom)
                            } label: {
                                ChatroomRowView(chatroom: chatroom)
                            }
                        }
                        .onDelete(perform: deleteChatroomAtOffsets)
                    }
                }
            }
            .navigationTitle("Chatrooms")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        databaseManager.signOut()
                    }) {
                        Text("Logout")
                            .foregroundStyle(.red)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showCreateChatroomView.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateChatroomView) {
                CreateChatroomView()
            }
        }
    }
    
    private func deleteChatroomAtOffsets(at offsets: IndexSet) {
        guard let deleteIndex = offsets.first else {
            return
        }
        Task {
            await databaseManager.deleteChatroom(databaseManager.chatrooms[deleteIndex])
        }
    }
}

#Preview("ChatroomsView") {
    ChatroomsView()
        .environment(DatabaseManager())
}
