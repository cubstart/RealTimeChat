//
//  RTCActionButton.swift
//  RealTimeChat
//
//  Created by Justin Wong on 4/12/25.
//

import SwiftUI

struct RTCActionButton: View {
    var title: String
    var backgroundColor: Color
    var actionHandler: () -> Void
    
    var body: some View {
        Button(action: {
           actionHandler()
        }) {
            HStack {
                Spacer()
                Text(title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [backgroundColor.opacity(0.5), backgroundColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: backgroundColor.opacity(0.4), radius: 10, x: -5, y: -5)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    RTCActionButton(title: "Login", backgroundColor: .blue) {}
}
