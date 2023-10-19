//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 02.04.2023.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
	private let storageManager = StorageManager.shared
    private let cellID = "task"
	private var featchedResultsController = StorageManager.shared.getFeatchedResultsController(
		entityName: "Task",
		keyForSort: "title"
	)
    
    override func viewDidLoad() {
        super.viewDidLoad()
		featchedResultsController.delegate = self
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchTasks()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		showAlert2(withTitle: "Update Task", andMessage: "What do you want to do?", indexPath: indexPath)
    }
    
    
    private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What do you want to do?")
    }
    
    private func fetchTasks() {
        do {
			try featchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
    
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { [weak self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
			self?.storageManager.saveTask(withTitle: task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
	
	private func showAlert2(withTitle title: String, andMessage message: String, indexPath: IndexPath) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		guard let task = self.featchedResultsController.object(at: indexPath) as? Task else { return }
		let saveAction = UIAlertAction(title: "Save Task", style: .default) { [weak self] _ in
			guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
			self?.storageManager.edit(task: task, with: title)
		}
		guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
		self.storageManager.saveTask(withTitle: title)
		let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
		alert.addAction(saveAction)
		alert.addAction(cancelAction)
		alert.addTextField { textField in
			textField.text = task.title
		}
		present(alert, animated: true)
	}
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [unowned self] _ in
                addNewTask()
            }
        )
        navigationController?.navigationBar.tintColor = .white
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
	) -> Int {
		featchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
		let task = featchedResultsController.object(at: indexPath) as? Task
        var content = cell.defaultContentConfiguration()
        content.text = task?.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - Table View Delegate
extension TaskListViewController {
	override func tableView(
		_ tableView: UITableView,
		trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
	) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
			if let task = self?.featchedResultsController.object(at: indexPath) as? Task {
				self?.storageManager.delete(task: task)
			}
		}
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension TaskListViewController: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controller(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>,
		didChange anObject: Any,
		at indexPath: IndexPath?,
		for type: NSFetchedResultsChangeType,
		newIndexPath: IndexPath?
	) {
		switch type {
		case .insert:
			guard let newIndexPath = newIndexPath else { return }
			tableView.insertRows(at: [newIndexPath], with: .automatic)
		case .delete:
			guard let indexPath = indexPath else { return }
			tableView.deleteRows(at: [indexPath], with: .automatic)
		default:
			tableView.reloadData()
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
}
