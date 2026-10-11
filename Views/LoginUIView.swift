//
//  LoginUIView.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 09/10/26.
//

import SwiftUI

struct LoginUIView: View {

    @StateObject private var viewModel = LoginViewModel()
    
    let onLoginSuccess : () -> Void

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            VStack(spacing: 8) {
                Text("Learning Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Sign in to continue learning")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {

                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                    

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
            }

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            
            Button {
                Task {
                    await viewModel.login()

                    if viewModel.isLoggedIn {
                        onLoginSuccess()
                    }
                }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Login")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
                .background(
                    viewModel.canLogin
                    ? Color.blue
                    : Color.gray
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 10)
                )
            }
            .disabled(!viewModel.canLogin || viewModel.isLoading)

            Spacer()
        }
        .padding(24)
    }
}

#Preview {
    LoginUIView{
        print("Login successful")
    }
}
