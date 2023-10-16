//
//  TasksStorageProtocol.swift
//  Todolist
//
//  Created by Юрий Демиденко on 15.10.2023.
//

import Foundation

protocol TasksStorageProtocol {
    var tasks: [String: Bool] { get }
    func save(_ tasks: [String: Bool], completion: ([String: Bool]) -> Void)
}
