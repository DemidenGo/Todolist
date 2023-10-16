//
//  TaskCell.swift
//  Todolist
//
//  Created by Юрий Демиденко on 15.10.2023.
//

import UIKit

final class TaskCell: UITableViewCell {

    static var identifier: String {
        String(describing: self)
    }

    private lazy var taskLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        customizeCell()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func customizeCell() {
        contentView.superview?.backgroundColor = .backgroundColor
        accessoryType = .checkmark
    }

    private func setupConstraints() {
        contentView.addSubview(taskLabel)
        NSLayoutConstraint.activate([
            taskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            taskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            taskLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func setup(with task: TaskViewModel) {
        taskLabel.text = task.name
        accessoryType = task.isCompleted ? .checkmark : .none
    }
}
