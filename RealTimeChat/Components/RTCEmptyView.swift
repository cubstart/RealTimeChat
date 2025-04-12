//
//  RTCEmptyView.swift
//  RealTimeChat
//
//  Created by Justin Wong on 4/11/25.
//

import SwiftUI

struct RTCEmptyView: View {
    var message: String
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "xmark.app")
                .font(.system(size: 40))
            Text(message)
                .fontWeight(.semibold)
                .font(.system(size: 20))
        }
        .foregroundStyle(.gray)
    }
}

#Preview {
    RTCEmptyView(message: "No Fetched Users")
}
