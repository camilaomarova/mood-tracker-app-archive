//
//  TaskViewList.swift
//  test
//
//  Created by Camila Omarova on 27.11.2023.
//

import SwiftUI

struct TaskListView: View {
    let tasks: [Task]
    
    init(tasks: [Task]) {
        self.tasks = tasks
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(tasks.indices, id: \.self) { index in
                    let task = tasks[index]
                    TaskRowView(task: task, isEvenRow: index % 2 == 0)
                        .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Task List")
        }
    }
}

struct TaskRowView: View {
    let task: Task
    let isEvenRow: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                Text("Mood: \(task.mood)")
                    .font(.subheadline)
                Text("Start Time: \(task.startTime) - Finish Time: \(task.finishTime)")
                    .font(.subheadline)
            }
            .padding(8)
            .foregroundColor(.black)
            .background(isEvenRow ? Color.white : Color.blue)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isEvenRow ? Color.blue : Color.white, lineWidth: 1)
            )
        }
        .padding(.vertical, 4)
    }
}

struct Task: Identifiable {
    let id: Int
    let userId: Int
    let mood: String
    let startTime: String
    let finishTime: String
    let title: String
    let description: String
    let priority: String
}

// Usage
let tasks = [/* ... */] // Your array of tasks
let taskListView = TaskListView(tasks: tasks)
