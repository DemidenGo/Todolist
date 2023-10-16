//
//  Array+Extensions.swift
//  Todolist
//
//  Created by Юрий Демиденко on 15.10.2023.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
