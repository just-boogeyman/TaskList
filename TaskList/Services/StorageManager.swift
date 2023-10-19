//
//  StorageManager.swift
//  TaskList
//
//  Created by Ярослав Кочкин on 12.10.2023.
//

import CoreData

final class StorageManager {
	static let shared = StorageManager()
	
	private let persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "TaskList")
		container.loadPersistentStores { storeDescription, error in
			if let error = error as NSError? {
				fatalError("Unresolvaed error \(error), \(error.userInfo)")
			}
		}
		return container
	}()
	
	private var viewContext: NSManagedObjectContext {
		persistentContainer.viewContext
	}
	
	private init() {}
	
	func saveContext() {
		if viewContext.hasChanges {
			do {
				try viewContext.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	func getFeatchedResultsController(
		entityName: String,
		keyForSort: String
	) -> NSFetchedResultsController<NSFetchRequestResult> {
		let featchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		let sortDescriptor = NSSortDescriptor(key: keyForSort, ascending: true)
		
		featchRequest.sortDescriptors = [sortDescriptor]
		
		let featchResultsController = NSFetchedResultsController(
			fetchRequest: featchRequest,
			managedObjectContext: viewContext,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		return featchResultsController
	}
	
	func saveTask(withTitle title: String) {
		let task = Task(context: viewContext)
		task.title = title
		saveContext()
	}
	
	func delete(task: Task) {
		viewContext.delete(task)
		saveContext()
	}
	
	func edit(task: Task, with newTitle: String) {
		task.title = newTitle
		saveContext()
	}
}
