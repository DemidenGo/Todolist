//
//  TasksListViewController.swift
//  Todolist
//
//  Created by Юрий Демиденко on 15.10.2023.
//

import UIKit

final class TasksListViewController: UIViewController {

    private let viewModel: TasksListViewModelProtocol
    private let notificationCenter: NotificationCenter
    private var tasksListBottomConstraint: NSLayoutConstraint

    private lazy var tasksListLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.tasksListTitle
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        return label
    }()

    private lazy var newTaskTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = Constants.newTaskNamePlaceholder
        textField.backgroundColor = .backgroundColor
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.leftView = textFieldIndentView
        textField.leftViewMode = .always
        textField.rightView = addNewTaskButton
        textField.rightViewMode = .whileEditing
        textField.delegate = self
        return textField
    }()

    private lazy var textFieldIndentView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
        return view
    }()

    private lazy var addNewTaskButton: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 6)
        let button = UIButton(configuration: buttonConfig)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let buttonImage = UIImage(systemName: Images.addTaskButton,
                                  withConfiguration: symbolConfig)?.withTintColor(.systemBlue)
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(addNewTask), for: .touchUpInside)
        return button
    }()

    private lazy var tasksListTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    init(viewModel: TasksListViewModelProtocol = TasksListViewModel()) {
        self.viewModel = viewModel
        self.notificationCenter = NotificationCenter.default
        self.tasksListBottomConstraint = NSLayoutConstraint()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupConstraints()
        hideKeyboardByTap()
        viewModel.viewDidLoad()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow),
                                       name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide),
                                       name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func bind() {
        viewModel.taskViewModelsObservable.bind { [weak self] _ in
            self?.tasksListTableView.performBatchUpdates({
                self?.tasksListTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            })
        }
    }

    private func setupConstraints() {
        [tasksListLabel, newTaskTextField, tasksListTableView].forEach { view.addSubview($0) }
        tasksListBottomConstraint = tasksListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            tasksListLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tasksListLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),

            newTaskTextField.topAnchor.constraint(equalTo: tasksListLabel.bottomAnchor, constant: 8),
            newTaskTextField.leadingAnchor.constraint(equalTo: tasksListLabel.leadingAnchor),
            newTaskTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            newTaskTextField.heightAnchor.constraint(equalToConstant: 36),

            tasksListTableView.topAnchor.constraint(equalTo: newTaskTextField.bottomAnchor, constant: 12),
            tasksListTableView.leadingAnchor.constraint(equalTo: newTaskTextField.leadingAnchor),
            tasksListBottomConstraint,
            tasksListTableView.trailingAnchor.constraint(equalTo: newTaskTextField.trailingAnchor)
        ])
    }

    private func hideKeyboardByTap() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tasksListBottomConstraint.constant = -keyboardSize.height + view.safeAreaInsets.bottom
        }
    }

    @objc private func keyboardWillHide() {
        tasksListBottomConstraint.constant = 0
    }

    @objc private func addNewTask() {
        if let newTask = newTaskTextField.text, newTask != "" {
            viewModel.didEnter(newTask)
            newTaskTextField.text = nil
        }
    }
}

// MARK: - UITableViewDataSource

extension TasksListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.taskViewModels.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier) as? TaskCell
        else { return UITableViewCell() }
        cell.setup(with: viewModel.taskViewModels[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TasksListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.taskDidSelect(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteTask(at: indexPath.row)
        }
    }
}

// MARK: - UITextFieldDelegate

extension TasksListViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }
}
