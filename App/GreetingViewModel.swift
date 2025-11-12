//
//  GreetingViewModel.swift
//  App
//
//  Created on 2025-11-10.
//

import Foundation

    class GreetingViewModel: ObservableObject {
        @Published var userName: String = ""

        private var model: GreetingModel

    init(model: GreetingModel = GreetingModel()) {
        self.model = GreetingModel()
        self.userName = model.userName
    }

    /// Returns the display name for the greeting
    /// Defaults to empty string if no name is available
    func getUserName() -> String {
        return userName.isEmpty ? "" : userName
    }

    /// Fetches the user name from the model/API
    func loadUserName() async {
        do {
            let name = try await model.fetchUserName()
            await MainActor.run {
                self.userName = name
            }
        } catch {
            // Handle error - keep default empty string
            await MainActor.run {
                self.userName = ""
            }
        }
    }
}
