//
//  LessonModel.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 08/10/26.
//

import Foundation

struct LessonModel: Identifiable {
    let id: Int64
    let courseId: Int64
    let title: String
    var isCompleted: Bool
}

