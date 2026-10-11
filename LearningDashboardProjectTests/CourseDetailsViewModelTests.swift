//
//  CourseDetailsViewModelTests.swift
//  LearningDashboardProjectTests
//
//  Created by Vasanth Mani on 10/10/26.
//

import XCTest
@testable import LearningDashboardProject

@MainActor
final class CourseDetailsViewModelTests: XCTestCase {

    func testProgressCalculation() async {

        let course = CourseModel(
            id: 1,
            title: "Python Programming",
            instructor: "John Smith",
            progress: 50,
            lessonsCount: 4
        )

        let repository = MockCourseRepository()

        let viewModel = CourseDetailsViewModel(
            course: course,
            repository: repository
        )

        await viewModel.loadLessons()

        XCTAssertEqual(viewModel.completedLessons, 2)
        XCTAssertEqual(viewModel.progress, 50)
    }
}

// MARK: - Mock Repository

final class MockCourseRepository: CourseRepositoryProtocol {

    func fetchCourses() async throws -> [CourseModel] {
        []
    }

    func fetchLessons(courseId: Int64) async throws -> [LessonModel] {

        [
            LessonModel(
                id: 1,
                courseId: 1,
                title: "Introduction",
                isCompleted: true
            ),
            LessonModel(
                id: 2,
                courseId: 1,
                title: "Variables",
                isCompleted: true
            ),
            LessonModel(
                id: 3,
                courseId: 1,
                title: "Functions",
                isCompleted: false
            ),
            LessonModel(
                id: 4,
                courseId: 1,
                title: "OOP",
                isCompleted: false
            )
        ]
    }

    func markLessonCompleted(
        lessonId: Int64,
        courseId: Int64
    ) async throws {
    }
}
