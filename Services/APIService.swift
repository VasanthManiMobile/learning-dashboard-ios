//
//  APIService.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 08/10/26.
//

import Foundation

protocol APIServiceProtocol {
    func fetchCourses() async throws -> [CourseModel]
    func fetchLessons(courseId: Int64) async throws -> [LessonModel]
}

final class APIService: APIServiceProtocol {
    
    static var shouldSimulateFailure = false
    
    func fetchCourses() async throws -> [CourseModel] {
        
        if APIService.shouldSimulateFailure {
            throw NSError(
                domain: "APIService",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Simulated API failure"
                ]
            )
        }
        
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(800))
        
        return [
            CourseModel(
                id: 1,
                title: "Python Programming",
                instructor: "John Smith",
                progress: 65,
                lessonsCount: 20
            ),
            CourseModel(
                id: 2,
                title: "Generative AI",
                instructor: "Sarah Williams",
                progress: 40,
                lessonsCount: 16
            ),
            CourseModel(
                id: 3,
                title: "Full Stack Development",
                instructor: "David Brown",
                progress: 25,
                lessonsCount: 28
            )
        ]
    }
    
    func fetchLessons(courseId: Int64) async throws -> [LessonModel] {
        
        try await Task.sleep(for: .milliseconds(500))
        
        switch courseId {
            
        case 1:
            return (1...20).map { index in
                LessonModel(
                    id: Int64(index),
                    courseId: 1,
                    title: "Python Lesson \(index)",
                    isCompleted: index <= 13
                )
            }
            
        case 2:
            return (1...16).map { index in
                LessonModel(
                    id: Int64(100 + index),
                    courseId: 2,
                    title: "Generative AI Lesson \(index)",
                    isCompleted: index <= 6
                )
            }
            
        case 3:
            return (1...28).map { index in
                LessonModel(
                    id: Int64(200 + index),
                    courseId: 3,
                    title: "Full Stack Lesson \(index)",
                    isCompleted: index <= 7
                )
            }
            
        default:
            return []
        }
    }
}
