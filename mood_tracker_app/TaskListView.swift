import SwiftUI

struct TaskListView: View {
    @State private var tasks: [CustomTask] = []
    let bearerToken: String
    let userId: String
    
    init(bearerToken: String = "defaultBearerToken", userId: String = "defaultUserId") {
        self.bearerToken = bearerToken
        self.userId = userId
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
            .onAppear(perform: fetchTasks) // Add onAppear to trigger the function when the view appears
        }
    }

    // Function to fetch tasks
    // Function to fetch tasks
    func fetchTasks() {
        // Your curl command to fetch tasks
        let url = URL(string: "http://localhost:8097/tasks/\(userId)")
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // Handle error
                return
            }

            do {
                let decodedTasks = try JSONDecoder().decode([CustomTask].self, from: data)
                DispatchQueue.main.async {
                    self.tasks = decodedTasks
                }
            } catch {
                // Handle decoding error
                print("Error decoding tasks: \(error)")
            }
        }.resume()
    }
}

struct TaskRowView: View {
    let task: CustomTask
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

struct CustomTask: Identifiable, Decodable {
    let id: Int
    let userId: Int
    let mood: String
    let startTime: String
    let finishTime: String
    let title: String
    let description: String
    let priority: String
}

