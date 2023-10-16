//
//  TasksListViewModelProtocol.swift
//  Todolist
//
//  Created by Юрий Демиденко on 15.10.2023.
//

import Foundation

protocol TasksListViewModelProtocol {
    var taskViewModels: [TaskViewModel] { get }
    var taskViewModelsObservable: Observable<[TaskViewModel]> { get }
    func viewDidLoad()
    func didEnter(_ newTask: String)
    func deleteTask(at index: Int)
    func taskDidSelect(at index: Int)
}
