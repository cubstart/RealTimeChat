//
//  CreateChatroomView.swift
//  RealTimeChat
//
//  Created by Justin Wong on 4/12/25.
//

import SwiftUI

struct CreateChatroomView: View {
    @Environment(DatabaseManager.self) private var databaseManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedUsers: Set<RTCUser> = Set()
    @State private var searchText = ""
    @State private var isFetchingUsers = false
    
    private var searchResults: [RTCUser] {
        var users = databaseManager.users.filter { !databaseManager.isCurrentUser($0) }
        
        if !searchText.isEmpty {
            users = databaseManager.users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        return users.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isFetchingUsers {
                    ProgressView()
                } else {
                    usersListView
                }
            }
            .navigationTitle("Create New Chatroom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            await databaseManager.createNewChatroom(with: Array(selectedUsers))
                            dismiss()
                        }
                    }) {
                        Text("Create")
                            .tint(.green)
                    }
                }
            }
            .onAppear {
                isFetchingUsers = true
                Task {
                    await databaseManager.fetchAllUsers()
                    isFetchingUsers = false
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search For A User")
    }
    
    @ViewBuilder
    private var usersListView: some View {
        if databaseManager.users.isEmpty {
            RTCEmptyView(message: "No Users Available")
        } else {
            if searchResults.isEmpty {
                RTCEmptyView(message: "No Matching Search Results")
            } else {
                List(searchResults) { user in
                    HStack {
                        Text(user.name)
                        Spacer()
                        Button(action: {
                            if selectedUsers.contains(user) {
                                selectedUsers.remove(user)
                            } else {
                                selectedUsers.insert(user)
                            }
                        }) {
                            Image(systemName: selectedUsers.contains(user) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                        }
                    }
                }
            }
        }
    }
}

#Preview("CreateChatroomView") {
    CreateChatroomView()
        .environment(DatabaseManager())
}
