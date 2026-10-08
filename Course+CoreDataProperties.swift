//
//  Course+CoreDataProperties.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 08/10/26.
//
//

public import Foundation
public import CoreData


public typealias CourseCoreDataPropertiesSet = NSSet

extension Course {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }

    @NSManaged nonisolated public var id: Int64
    @NSManaged nonisolated public var instructor: String?
    @NSManaged nonisolated public var lessonsCount: Int64
    @NSManaged nonisolated public var progress: Double
    @NSManaged nonisolated public var title: String?

}

extension Course : Identifiable {

}
