//
//  Lesson+CoreDataProperties.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 08/10/26.
//
//

public import Foundation
public import CoreData


public typealias LessonCoreDataPropertiesSet = NSSet

extension Lesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged nonisolated public var courseId: Int64
    @NSManaged nonisolated public var id: Int64
    @NSManaged nonisolated public var isCompleted: Bool
    @NSManaged nonisolated public var title: String?

}

extension Lesson : Identifiable {

}
