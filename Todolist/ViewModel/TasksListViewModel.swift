//
//  TasksListViewModel.swift
//  Todolist
//
//  Created by Юрий Демиденко on 15.10.2023.
//

import Foundation

final class TasksListViewModel {

    private let tasksStorage: TasksStorageProtocol

    @Observable
    private(set) var taskViewModels: [TaskViewModel]

    init(tasksStorage: TasksStorageProtocol = TasksStorage()) {
        self.tasksStorage = tasksStorage
        self.taskViewModels = []
    }

    private func makeViewModels(from tasks: [String: Bool]) {
        taskViewModels = tasks.map { TaskViewModel(name: $0, isCompleted: $1) }.sorted { $0.name < $1.name }
    }
}

// MARK: - TasksListViewModelProtocol

extension TasksListViewModel: TasksListViewModelProtocol {

    var taskViewModelsObservable: Observable<[TaskViewModel]> { $taskViewModels }

    func viewDidLoad() {
        makeViewModels(from: tasksStorage.tasks)
    }

    func didEnter(_ newTask: String) {
        var tasks = tasksStorage.tasks
        tasks[newTask] = false
        tasksStorage.save(tasks) { [weak self] updatedTasks in
            self?.makeViewModels(from: updatedTasks)
        }
    }

    func deleteTask(at index: Int) {
        guard let deletedTaskName = taskViewModels[safe: index]?.name else { return }
        var tasks = tasksStorage.tasks
        tasks[deletedTaskName] = nil
        tasksStorage.save(tasks) { [weak self] updatedTasks in
            self?.makeViewModels(from: updatedTasks)
        }
    }

    func taskDidSelect(at index: Int) {
        guard let selectedTask = taskViewModels[safe: index] else { return }
        var tasks = tasksStorage.tasks
        tasks[selectedTask.name] = selectedTask.isCompleted ? false : true
        tasksStorage.save(tasks) { [weak self] updatedTasks in
            self?.makeViewModels(from: updatedTasks)
        }
    }
}
