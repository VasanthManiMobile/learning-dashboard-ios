//
//  LoginViewModel.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 09/10/26.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoggedIn = false
    @Published var isLoading = false

    var canLogin: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }

    func login() async {

        errorMessage = ""

        // Validate email
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            return
        }

        // Validate password
        guard !password.isEmpty else {
            errorMessage = "Please enter your password."
            return
        }

        // Loading state
        isLoading = true
        isLoggedIn = false

        // Simulate login API
        do {
            try await Task.sleep(for: .milliseconds(800))

            // Mock successful login
            isLoggedIn = true

        } catch {
            errorMessage = "Unable to login. Please try again."
        }

        isLoading = false
    }

    private func isValidEmail(_ email: String) -> Bool {

        let emailRegex =
            "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        return email.range(
            of: emailRegex,
            options: .regularExpression
        ) != nil
    }
}
