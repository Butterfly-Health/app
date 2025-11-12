//
//  GreetingModel.swift
//  App
//
//  Created on 2025-11-10.
//

import Foundation

struct GreetingModel {
    var userName: String

    init(userName: String = "") {
        self.userName = userName
    }

    // TODO: Link this to the API to fetch the user's name
    // This method will be implemented to call the backend API
    // and return the actual user name from the server
    func fetchUserName() async throws -> String {
        // API call will be implemented here
        return ""
    }
}
