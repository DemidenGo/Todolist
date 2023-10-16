//
//  TasksStorage.swift
//  Todolist
//
//  Created by Юрий Демиденко on 15.10.2023.
//

import Foundation

final class TasksStorage: TasksStorageProtocol {

    private enum Keys: String {
        case tasks
    }

    private let userDefaults: UserDefaults

    private(set) var tasks: [String: Bool] {
        get {
            if let tasks = userDefaults.dictionary(forKey: Keys.tasks.rawValue) as? [String: Bool] {
                return tasks
            }
            return [:]
        }
        set {
            userDefaults.set(newValue, forKey: Keys.tasks.rawValue)
        }
    }

    init() {
        self.userDefaults = UserDefaults.standard
    }

    func save(_ tasks: [String: Bool], completion: ([String: Bool]) -> Void) {
        self.tasks = tasks
        completion(self.tasks)
    }
}
