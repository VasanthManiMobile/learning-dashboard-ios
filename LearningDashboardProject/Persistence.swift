//
//  Persistence.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 08/10/26.
//

import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let course = Course(context: viewContext)
        course.id = 1
        course.title = "Python Programming"
        course.instructor = "John Smith"
        course.progress = 50
        course.lessonsCount = 4

        let lesson1 = Lesson(context: viewContext)
        lesson1.id = 1
        lesson1.courseId = 1
        lesson1.title = "Introduction"
        lesson1.isCompleted = true

        let lesson2 = Lesson(context: viewContext)
        lesson2.id = 2
        lesson2.courseId = 1
        lesson2.title = "Variables & Data Types"
        lesson2.isCompleted = true

        let lesson3 = Lesson(context: viewContext)
        lesson3.id = 3
        lesson3.courseId = 1
        lesson3.title = "Functions"
        lesson3.isCompleted = false

        let lesson4 = Lesson(context: viewContext)
        lesson4.id = 4
        lesson4.courseId = 1
        lesson4.title = "Object-Oriented Programming"
        lesson4.isCompleted = false

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {

        container = NSPersistentContainer(
            name: "LearningDashboardProject"
        )

        if inMemory {
            container.persistentStoreDescriptions.first?.url =
                URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in

            if let error = error as NSError? {
                fatalError(
                    "Unresolved error \(error), \(error.userInfo)"
                )
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
    }
}
