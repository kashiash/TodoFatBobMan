import Core
import CoreData
@testable import DB
import XCTest

@MainActor
final class DBTests: XCTestCase {

    func testNewGroup() async throws {
        let stack = CoreDataStack.test
        let todoGroup = TodoGroup(id: .integer(0), title: "hello", taskCount: 0)
        await stack._createNewGroup(todoGroup)
        let request = NSFetchRequest<C_Group>(entityName: "C_Group")
        request.sortDescriptors = [.init(key: "title", ascending: true)]
        let result = try stack.viewContext.fetch(request)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, todoGroup.title)
    }

    func testUpdateGroup() async throws {
        let stack = CoreDataStack.test
        let todoGroup = TodoGroup(id: .integer(0), title: "hello", taskCount: 0)
        await stack._createNewGroup(todoGroup)
        let request = NSFetchRequest<C_Group>(entityName: "C_Group")
        request.sortDescriptors = [.init(key: "title", ascending: true)]
        var group = try stack.viewContext.fetch(request).first!.convertToValueType()
        // change
        group.title = "New"
        await stack._updateGroup(group)
        let newGroup = try stack.viewContext.fetch(request).first!.convertToValueType()
        XCTAssertEqual(group.id, newGroup.id)
        XCTAssertEqual(newGroup.title, "New")
    }

    func testDeleteGroup() async throws {
        let stack = CoreDataStack.test
        let todoGroup = TodoGroup(id: .integer(0), title: "hello", taskCount: 0)
        await stack._createNewGroup(todoGroup)
        let request = NSFetchRequest<C_Group>(entityName: "C_Group")
        request.sortDescriptors = [.init(key: "title", ascending: true)]
        let group = try stack.viewContext.fetch(request).first!.convertToValueType()
        await stack._deleteGroup(group)
        let count = try stack.viewContext.fetch(request).count
        XCTAssertEqual(count, 0)
    }

    func testCreateNewTask() async throws {
        let stack = CoreDataStack.test
        let todoGroup = TodoGroup.sample1
        await stack._createNewGroup(todoGroup)
        let request = NSFetchRequest<C_Group>(entityName: "C_Group")
        request.sortDescriptors = [.init(key: "title", ascending: true)]
        let group = try stack.viewContext.fetch(request).first!

        let task = TodoTask.sample1
        await stack._createNewTask(task, group.convertToValueType())
        let taskRequest = NSFetchRequest<C_Task>(entityName: "C_Task")
        taskRequest.sortDescriptors = [.init(key: "title", ascending: true)]
        let result = try stack.viewContext.fetch(taskRequest)
        XCTAssertEqual(result.count, 1)
        let todoTask = result.first!

        XCTAssertEqual(todoTask.group?.id, group.id)
    }

    func testCreateNewTaskWithoutGroup() async throws {
        let stack = CoreDataStack.test

        let task = TodoTask.sample1
        await stack._createNewTask(task, nil)
        let taskRequest = NSFetchRequest<C_Task>(entityName: "C_Task")
        taskRequest.sortDescriptors = [.init(key: "title", ascending: true)]
        let result = try stack.viewContext.fetch(taskRequest)
        XCTAssertEqual(result.count, 1)
        let todoTask = result.first!

        XCTAssertEqual(todoTask.title,task.title)
    }

    func testUpdateTask() async throws {
        let stack = CoreDataStack.test
        let task = TodoTask.sample1
        await stack._createNewTask(task, nil)
        let taskRequest = NSFetchRequest<C_Task>(entityName: "C_Task")
        taskRequest.sortDescriptors = [.init(key: "title", ascending: true)]
        var todoTask = try stack.viewContext.fetch(taskRequest).first!.convertToValueType()
        todoTask.title = "New"
        await stack._updateTask(todoTask)
        let newTask = try stack.viewContext.fetch(taskRequest).first!.convertToValueType()
        XCTAssertEqual(newTask.id,todoTask.id)
        XCTAssertEqual(newTask.title, "New")
    }

    func testDeleteTask() async throws {
        let stack = CoreDataStack.test
        let task = TodoTask.sample1
        await stack._createNewTask(task, nil)
        let taskRequest = NSFetchRequest<C_Task>(entityName: "C_Task")
        taskRequest.sortDescriptors = [.init(key: "title", ascending: true)]
        let todoTask = try stack.viewContext.fetch(taskRequest).first!.convertToValueType()
        await stack._deleteTask(todoTask)
        XCTAssertEqual(0, try! stack.viewContext.fetch(taskRequest).count)
    }

    func testMoveTask() async throws {
        let stack = CoreDataStack.test
        let task = TodoTask.sample1
        await stack._createNewTask(task, nil)
        let taskRequest = NSFetchRequest<C_Task>(entityName: "C_Task")
        taskRequest.sortDescriptors = [.init(key: "title", ascending: true)]
        let todoTask = try stack.viewContext.fetch(taskRequest).first!.convertToValueType()
        let group = TodoGroup.sample1
        await stack._createNewGroup(group)
        let groupRequest = C_Group.fetchRequest()
        groupRequest.sortDescriptors = [.init(key: "title", ascending: true)]
        let todoGroupObject = try stack.viewContext.fetch(groupRequest).first!
        let todoGroup = todoGroupObject.convertToValueType()
        await stack._moveTask(todoTask, todoGroup)
        let newTask = try stack.viewContext.fetch(taskRequest).first!
        XCTAssertEqual(newTask.group?.id, todoGroup.id)
    }
}