//
//  ContentView.swift
//  RealTimeChat
//
//  Created by Justin Wong on 4/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var databaseManager = DatabaseManager()
    
    @State private var isCreatingNewUser = false
    @State private var userEmailText = ""
    @State private var userPasswordText = ""
    
    var body: some View {
        if databaseManager.isAuthChanging {
            ProgressView()
        } else {
            if databaseManager.currentUser != nil {
                ChatroomsView()
                    .environment(databaseManager)
            } else {
                VStack {
                    Spacer()
                    titleView
                    Spacer()
                    TextFieldHeaderSectionView(title: "Email", placeholder: "johnnyappleseed@apple.com", text: $userEmailText)
                    TextFieldHeaderSectionView(title: "Password", placeholder: "", text: $userPasswordText)
                    dontHaveAnAccountButton
                    Spacer()
                    signInUserButton
                    Spacer()
                }
                .padding()
                .sheet(isPresented: $isCreatingNewUser) {
                    CreateNewUserView()
                        .environment(databaseManager)
                }
            }
        }
    }
    
    private var titleView: some View {
        HStack {
            Text("🗣️ Real Time Chat")
                .font(.title)
                .fontWeight(.heavy)
        }
    }
    
    private var dontHaveAnAccountButton: some View {
        Button(action: {
            withAnimation {
                isCreatingNewUser.toggle()
            }
        }) {
            Text("Don't have an account?")
                .font(.system(size: 13))
        }
    }
    
    private var signInUserButton: some View {
        RTCActionButton(title: "Login In", backgroundColor: .blue) {
            databaseManager.signInUser(withEmail: userEmailText, withPassword: userPasswordText)
            userEmailText = ""
            userPasswordText = ""
        }
    }
}

struct CreateNewUserView: View {
    @Environment(DatabaseManager.self) private var databaseManager
    @Environment(\.dismiss) private var dismiss

    @State private var userNameText = ""
    @State private var userEmailText = ""
    @State private var userPasswordText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                TextFieldHeaderSectionView(title: "Name", placeholder: "Johnny Appleseed", text: $userNameText)
                TextFieldHeaderSectionView(title: "Email", placeholder: "johnnyappleseed@apple.com", text: $userEmailText)
                TextFieldHeaderSectionView(title: "Password", placeholder: "", text: $userPasswordText)
                createNewUserButton
                Spacer()
            }
            .padding()
            .navigationTitle("Create New Account")
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
            }
        }
    }
    
    private var createNewUserButton: some View {
        RTCActionButton(title: "Create Account", backgroundColor: .green) {
            databaseManager.createNewUser(withEmail: userEmailText, withPassword: userPasswordText, name: userNameText)
            userNameText = ""
            userEmailText = ""
            userPasswordText = ""
        }
        .padding(.top, 40)
    }
}

// MARK: - TextFieldHeaderSectionView

struct TextFieldHeaderSectionView: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .bold()
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview {
    ContentView()
}
