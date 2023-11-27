//
//  ContentView.swift
//  mood_tracker_app
//
//  Created by Camila Omarova on 19.11.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var bearerToken: String?
    @State private var userId: String?
    @State private var shouldNavigateToTaskView = false  // New flag to control navigation

    var body: some View {
        NavigationView {
            if isLoggedIn {
                TabView {
                    TaskView(userId: userId ?? "", bearerToken: bearerToken ?? "")
                        .tabItem {
                            Label("Tasks", systemImage: "list.bullet")
                        }
                    AnalyzeView(userId: userId ?? "", bearerToken: bearerToken ?? "")
                        .tabItem {
                            Label("Analyze", systemImage: "chart.bar.xaxis")
                        }
                }
                .onAppear {
                    // Check if the bearer token is active (you may need to implement this logic)
                    let isBearerTokenActive = isBearerTokenActive()  // Implement this function
                    if isBearerTokenActive {
                        // Set the flag to navigate to TaskView
                        shouldNavigateToTaskView = true
                    }
                }
                .background(
                    NavigationLink(
                        destination: TaskView(userId: userId ?? "", bearerToken: bearerToken ?? ""),
                        isActive: $shouldNavigateToTaskView
                    ) {
                        EmptyView()
                    }
                    .isDetailLink(false)
                    .hidden()
                )
            } else {
                LoginView()
                    .tabItem {
                        Label("Login", systemImage: "key.fill")
                    }

                RegisterView()
                    .tabItem {
                        Label("Register", systemImage: "person.crop.circle.badge.plus")
                    }
            }
        }
    }
    
    private func isBearerTokenActive() -> Bool {
        guard let tokenExpirationDate = getBearerTokenExpirationDate() else {
            // If there is no expiration date, consider the token as inactive
            return false
        }

        // Compare the current date and time with the token expiration date
        let currentDate = Date()
        return currentDate < tokenExpirationDate
    }

    // Example function to get the bearer token expiration date (replace with actual logic)
    private func getBearerTokenExpirationDate() -> Date? {
        // Replace this with the actual way you retrieve the expiration date from the token
        // For example, if the token is a JWT, you can decode it to get the expiration claim
        // This is just a placeholder, and you should implement it based on your authentication system
        return Date().addingTimeInterval(24 * 60 * 60)  // Assuming the token is valid for 24 hours
    }
}
