//
//  DashboardViewModel.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 09/10/26.
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {

    enum State {
        case loading
        case success
        case empty
        case error(String)
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var courses: [CourseModel] = []

    private let repository: CourseRepositoryProtocol

    init(
        repository: CourseRepositoryProtocol? = nil
    ) {
        self.repository = repository ?? CourseRepository()
    }

    func loadCourses() async {

        // Show loading only on the first load.
        if courses.isEmpty {
            state = .loading
        }

        do {
            let result = try await repository.fetchCourses()

            courses = result

            if result.isEmpty {
                state = .empty
            } else {
                state = .success
            }

        } catch {

            // Only show the error screen if we don't already
            // have courses displayed.
            if courses.isEmpty {
                state = .error(
                    "Unable to load courses. Please try again."
                )
            }
        }
    }
    
}
