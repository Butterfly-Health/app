//
//  GreetingView.swift
//  App
//
//  Created on 2025-11-10.
//

import SwiftUI

struct GreetingView: View {
    @ObservedObject var viewModel: GreetingViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6))
                Image(systemName: "face.smiling").font(.system(size: 24)).foregroundColor(.orange)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.title3).fontWeight(.semibold)
                Text("How are you feeling today?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .task {
            await viewModel.loadUserName()
        }
    }

    private var greetingText: String {
        let userName = viewModel.getUserName()
        if userName.isEmpty {
            return "Good morning"
        } else {
            return "Good morning, \(userName)"
        }
    }
}

#Preview {
    GreetingView(viewModel: GreetingViewModel())
}
