//
//  CourseModel.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 08/10/26.
//

import Foundation

struct CourseModel: Identifiable {
    let id: Int64
    let title: String
    let instructor: String
    var progress: Double
    let lessonsCount: Int64
}

