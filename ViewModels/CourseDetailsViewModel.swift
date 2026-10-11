//
//  CourseDetailsViewModel.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 09/10/26.
//

import Foundation
import Combine

@MainActor
final class CourseDetailsViewModel: ObservableObject {

    @Published private(set) var lessons: [LessonModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    let course: CourseModel

    private let repository: CourseRepositoryProtocol

    init(
        course: CourseModel,
        repository: CourseRepositoryProtocol? = nil
    ) {
        self.course = course
        self.repository = repository ?? CourseRepository()
    }

    var completedLessons: Int {
        lessons.filter { $0.isCompleted }.count
    }

    var progress: Double {
        guard !lessons.isEmpty else {
            return course.progress
        }

        return (Double(completedLessons) / Double(lessons.count)) * 100
    }

    func loadLessons() async {

        isLoading = true
        errorMessage = ""

        do {
            lessons = try await repository.fetchLessons(
                courseId: course.id
            )
        } catch {
            errorMessage = "Unable to load lessons."
        }

        isLoading = false
    }

    func completeLesson(_ lesson: LessonModel) async {

        guard !lesson.isCompleted else {
            return
        }

        do {
            try await repository.markLessonCompleted(
                lessonId: lesson.id,
                courseId: lesson.courseId
            )

            if let index = lessons.firstIndex(
                where: { $0.id == lesson.id }
            ) {
                lessons[index].isCompleted = true
            }

        } catch {
            errorMessage = "Unable to update lesson."
        }
    }
}
