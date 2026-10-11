//
//  CourseRepository.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 10/10/26.
//

import Foundation
import CoreData

protocol CourseRepositoryProtocol {
    func fetchCourses() async throws -> [CourseModel]
    func fetchLessons(courseId: Int64) async throws -> [LessonModel]
    func markLessonCompleted(
        lessonId: Int64,
        courseId: Int64
    ) async throws
}

final class CourseRepository: CourseRepositoryProtocol {

    private let apiService: APIServiceProtocol
    private let context: NSManagedObjectContext

    init(
        apiService: APIServiceProtocol = APIService(),
        context: NSManagedObjectContext =
            PersistenceController.shared.container.viewContext
    ) {
        self.apiService = apiService
        self.context = context
    }

    // MARK: - Courses

    func fetchCourses() async throws -> [CourseModel] {

        do {
            // Try API first
            let apiCourses = try await apiService.fetchCourses()

            // Merge API data with locally stored progress
            let courses = mergeCoursesWithLocalProgress(apiCourses)

            // Cache merged data locally
            saveCoursesToCoreData(courses)

            return courses

        } catch {

            // API failed → use offline data
            let cachedCourses = fetchCachedCourses()

            if !cachedCourses.isEmpty {
                return cachedCourses
            }

            throw error
        }
    }

    // MARK: - Lessons

    func fetchLessons(courseId: Int64) async throws -> [LessonModel] {

        do {
            let apiLessons = try await apiService.fetchLessons(
                courseId: courseId
            )

            // Merge API lessons with locally completed lessons
            let lessons = mergeLessonsWithLocalCompletion(apiLessons)

            saveLessonsToCoreData(lessons)

            return lessons

        } catch {

            let cachedLessons = fetchCachedLessons(
                courseId: courseId
            )

            if !cachedLessons.isEmpty {
                return cachedLessons
            }

            throw error
        }
    }
    
    private func mergeLessonsWithLocalCompletion(
        _ apiLessons: [LessonModel]
    ) -> [LessonModel] {

        return apiLessons.map { apiLesson in

            let request: NSFetchRequest<Lesson> =
                Lesson.fetchRequest()

            request.predicate = NSPredicate(
                format: "id == %lld AND courseId == %lld",
                apiLesson.id,
                apiLesson.courseId
            )

            if let localLesson =
                try? context.fetch(request).first {

                return LessonModel(
                    id: apiLesson.id,
                    courseId: apiLesson.courseId,
                    title: apiLesson.title,
                    isCompleted: localLesson.isCompleted
                )
            }

            return apiLesson
        }
    }

    // MARK: - Update Lesson

    func markLessonCompleted(
        lessonId: Int64,
        courseId: Int64
    ) async throws {

        let request: NSFetchRequest<Lesson> =
            Lesson.fetchRequest()

        request.predicate = NSPredicate(
            format: "id == %lld AND courseId == %lld",
            lessonId,
            courseId
        )

        if let lesson = try context.fetch(request).first {
            lesson.isCompleted = true
        }

        try context.save()

        updateCourseProgress(courseId: courseId)
    }

    // MARK: - Merge API + Local Progress

    private func mergeCoursesWithLocalProgress(
        _ apiCourses: [CourseModel]
    ) -> [CourseModel] {

        return apiCourses.map { apiCourse in

            let request: NSFetchRequest<Course> =
                Course.fetchRequest()

            request.predicate = NSPredicate(
                format: "id == %lld",
                apiCourse.id
            )

            if let localCourse = try? context.fetch(request).first {

                return CourseModel(
                    id: apiCourse.id,
                    title: apiCourse.title,
                    instructor: apiCourse.instructor,
                    progress: localCourse.progress,
                    lessonsCount: apiCourse.lessonsCount
                )
            }

            return apiCourse
        }
    }

    // MARK: - Core Data - Save Courses

    private func saveCoursesToCoreData(
        _ courses: [CourseModel]
    ) {

        for courseModel in courses {

            let request: NSFetchRequest<Course> =
                Course.fetchRequest()

            request.predicate = NSPredicate(
                format: "id == %lld",
                courseModel.id
            )

            let course: Course

            if let existingCourse =
                try? context.fetch(request).first {

                course = existingCourse

            } else {

                course = Course(context: context)
            }

            course.id = courseModel.id
            course.title = courseModel.title
            course.instructor = courseModel.instructor
            course.progress = courseModel.progress
            course.lessonsCount = courseModel.lessonsCount
        }

        try? context.save()
    }

    // MARK: - Core Data - Save Lessons

    private func saveLessonsToCoreData(
        _ lessons: [LessonModel]
    ) {

        for lessonModel in lessons {

            let request: NSFetchRequest<Lesson> =
                Lesson.fetchRequest()

            request.predicate = NSPredicate(
                format: "id == %lld",
                lessonModel.id
            )

            let lesson: Lesson

            if let existingLesson =
                try? context.fetch(request).first {

                lesson = existingLesson

            } else {

                lesson = Lesson(context: context)
            }

            lesson.id = lessonModel.id
            lesson.courseId = lessonModel.courseId
            lesson.title = lessonModel.title

            // Preserve locally completed lessons.
            if !lesson.isCompleted {
                lesson.isCompleted = lessonModel.isCompleted
            }
        }

        try? context.save()
    }

    // MARK: - Core Data - Cached Courses

    private func fetchCachedCourses() -> [CourseModel] {

        let request: NSFetchRequest<Course> =
            Course.fetchRequest()

        guard let courses =
            try? context.fetch(request) else {

            return []
        }

        return courses.map {
            CourseModel(
                id: $0.id,
                title: $0.title ?? "",
                instructor: $0.instructor ?? "",
                progress: $0.progress,
                lessonsCount: $0.lessonsCount
            )
        }
    }

    // MARK: - Core Data - Cached Lessons

    private func fetchCachedLessons(
        courseId: Int64
    ) -> [LessonModel] {

        let request: NSFetchRequest<Lesson> =
            Lesson.fetchRequest()

        request.predicate = NSPredicate(
            format: "courseId == %lld",
            courseId
        )

        guard let lessons =
            try? context.fetch(request) else {

            return []
        }

        return lessons.map {
            LessonModel(
                id: $0.id,
                courseId: $0.courseId,
                title: $0.title ?? "",
                isCompleted: $0.isCompleted
            )
        }
    }

    // MARK: - Progress

    private func updateCourseProgress(
        courseId: Int64
    ) {

        let lessonRequest: NSFetchRequest<Lesson> =
            Lesson.fetchRequest()

        lessonRequest.predicate = NSPredicate(
            format: "courseId == %lld",
            courseId
        )

        guard let lessons =
            try? context.fetch(lessonRequest),
            !lessons.isEmpty else {

            return
        }

        let completedCount = lessons.filter {
            $0.isCompleted
        }.count

        let progress =
            (Double(completedCount) /
             Double(lessons.count)) * 100

        let courseRequest: NSFetchRequest<Course> =
            Course.fetchRequest()

        courseRequest.predicate = NSPredicate(
            format: "id == %lld",
            courseId
        )

        if let course =
            try? context.fetch(courseRequest).first {

            course.progress = progress
        }

        try? context.save()
    }
}
