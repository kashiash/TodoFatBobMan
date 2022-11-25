//
//  TaskListContainer.swift
//  PureSwiftUI
//
//  Created by Yang Xu on 2022/11/24.
//

import Core
import Foundation
import SwiftUI
import ViewLibrary

struct TaskListContainerView: View {
    @Environment(\.updateTask) private var updateTaskEnv
    @Environment(\.createNewTask) private var createNewTaskEnv
    @Environment(\.deleteTask) private var deleteTaskEnv
    @Environment(\.moveTask) private var moveTaskEnv

    @State private var taskToBeDeleted: TodoTask?
    @State private var selectedTask: TodoTask?
    @State private var taskToBeMoved: TodoTask?
    @State private var sortType: TaskSortType = .title

    private let taskSource: TaskSource

    init(taskSource: TaskSource) {
        self.taskSource = taskSource
    }

    var body: some View {
        TaskListView(
            taskSource: taskSource,
            taskSortType: sortType,
            updateTask: updateTask,
            deleteTaskButtonTapped: deleteTaskButtonTapped,
            moveTaskButtonTapped: moveTaskButtonTapped,
            taskCellTapped: taskCellTapped
        )
        .safeAreaInset(edge: .bottom) {
            InputNewTaskView(
                taskSource: taskSource,
                createNewTask: createNewTask
            )
        }
        // 目前用 navigationTitle 有闪烁 bug
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                TaskSortButton(taskSortType: $sortType)
            }
            ToolbarItem(placement: .principal) {
                Text(taskListTitle).bold()
            }
        }
        .sheet(isPresented: .isPresented($taskToBeMoved)) {
            if let taskToBeMoved {
                MoveTaskToNewGroupView(
                    task: taskToBeMoved,
                    dismiss: { self.taskToBeMoved = nil },
                    taskCellTapped: taskCellTapped
                )
            }
        }
        .alert(
            "Delete Task",
            isPresented: .isPresented($taskToBeDeleted),
            actions: {
                Button("Confirm", role: .destructive) {
                    performDeleteTask()
                }
                Button("Cancel", role: .cancel) {}
            },
            message: {
                Text("Once deleted, data is irrecoverable")
            }
        )
        .navigationDestination(isPresented: .isPresented($selectedTask)) {
            TaskEditorContainerView(
                task: selectedTask ?? .placeHold
            )
            .id(self.selectedTask == nil) // 解决因为预创建实例，导致的视图 body 值不正确的问题
        }
    }

    private var taskListTitle: String {
        switch taskSource {
        case .all:
            return "All Tasks"
        case .completed:
            return "Completed Tasks"
        case .myDay:
            return "My Day Tasks"
        case .list(let group):
            return group.title
        default:
            return ""
        }
    }

    private func dismissTaskDetail() {
        self.selectedTask = nil
    }

    private func deleteTaskButtonTapped(task: TodoTask) {
        taskToBeDeleted = task
    }

    private func performDeleteTask() {
        guard let taskToBeDeleted else { return }
        Task { await deleteTaskEnv(taskToBeDeleted) }
    }

    private func taskCellTapped(task: TodoTask) {
        selectedTask = task
    }

    private func updateTask(task: TodoTask) {
        Task {
            await updateTaskEnv(task)
        }
    }

    private func createNewTask(task: TodoTask, taskSource: TaskSource) {
        Task {
            await createNewTaskEnv(task, taskSource)
        }
    }

    private func moveTaskButtonTapped(task: TodoTask) {
        taskToBeMoved = task
    }

    private func taskCellTapped(taskID: WrappedID, groupID: WrappedID) {
        Task { await moveTaskEnv(taskID, groupID) }
    }
}

#if DEBUG
final class ListContainerDataSource: ObservableObject {
    @Published var tasks = [
        MockTask(.sample1).eraseToAny(),
        MockTask(.sample2).eraseToAny(),
        MockTask(.sample3).eraseToAny()
    ]

    var completed: [AnyConvertibleValueObservableObject<TodoTask>] {
        tasks.filter { $0.wrappedValue.completed }
    }

    var unCompleted: [AnyConvertibleValueObservableObject<TodoTask>] {
        tasks.filter { !$0.wrappedValue.completed }
    }

    static let share = ListContainerDataSource()
}

struct TaskListContainerRootForPreview: View {
    @StateObject var dataSource = ListContainerDataSource()
    @State var id = UUID()
    var body: some View {
        VStack {
            TaskListContainerView(taskSource: .myDay)
                .transformEnvironment(\.dataSource) {
                    $0.unCompletedTasks = .mockObjects(.init(dataSource.unCompleted))
                    $0.completedTasks = .mockObjects(.init(dataSource.completed))
                }
                .environment(\.deleteTask) { task in
                    await MainActor.run {
                        guard let index = dataSource.tasks.firstIndex(where: { $0.id == task.id }) else { return }
                        dataSource.tasks.remove(at: index)
                    }
                }
                .environment(\.updateTask) { task in
                    await MainActor.run {
                        guard let index = dataSource.tasks.firstIndex(where: { $0.id == task.id }) else { return }
                        (dataSource.tasks[index]._object as? MockTask)?.update(task)
                        id = UUID()
                    }
                }
                .environment(\.createNewTask) { task, _ in
                    await MainActor.run {
                        let newTask: TodoTask = .init(
                            id: .uuid(UUID()),
                            priority: task.priority,
                            createDate: task.createDate,
                            title: task.title,
                            completed: task.completed,
                            myDay: task.myDay
                        )
                        dataSource.tasks.append(MockTask(newTask).eraseToAny())
                    }
                }
//                .id(id) // 解决 preview 中，transformEnvironment 不刷新的问题
        }
    }
}

struct TaskListContainerPreview: PreviewProvider {
    static var previews: some View {
        TaskListContainerRootForPreview()
    }
}
#endif

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
