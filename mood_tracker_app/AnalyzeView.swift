import Foundation
import SwiftUI

//struct LineGraph: View {
//    let data: [String: [(String, String)]]?
//    let title: String
//    let moodNames: [String]
//
//    var body: some View {
//        VStack {
//            Text(title)
//                .font(.headline)
//                .padding()
//
//            if let data = data {
//                LineChart(data: data, moodNames: moodNames)
//                    .frame(height: 200)
//            }
//        }
//        .padding()
//    }
//}

struct LineChart: View {
    let data: [String: [(String, String)]]
    let moodNames: [String]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(moodNames, id: \.self) { mood in
                    if let timeRanges = data[mood] {
                        LineGraphLine(data: timeRanges)
                            .stroke(lineColor(for: mood), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    }
                }
            }
        }
    }

    private func lineColor(for mood: String) -> Color {
        // Assign different colors based on mood
        switch mood {
        case "Energetic": return .red
        case "Relaxed": return .yellow
        case "Creative": return .green
        case "OtherMood": return .indigo // Add more cases as needed
        default: return .gray
        }
    }
}

struct LineGraphLine: Shape {
    let data: [(String, String)]

    func path(in rect: CGRect) -> Path {
        var path = Path()

        for (index, timeRange) in data.enumerated() {
            guard let value = Int(timeRange.1) else {
                // Handle the case where the value is nil (e.g., show an error, skip the point, etc.)
                continue
            }

            let x = rect.width / CGFloat(data.count - 1) * CGFloat(index)
            let y = rect.height - CGFloat(value * 10) // Adjust the scaling factor as needed

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }
}

struct AnalyzeView: View {
    let userId: String
    let bearerToken: String

    init(userId: String, bearerToken: String) {
        self.userId = userId
        self.bearerToken = bearerToken
    }

    let pastelBlueColor = Color(red: 0.6, green: 0.8, blue: 1.0)

    struct PastelBlueButtonStyle: ButtonStyle {
        let pastelBlueColor = Color(red: 0.6, green: 0.8, blue: 1.0)

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(pastelBlueColor))
                .foregroundColor(.white)
        }
    }

    @State private var shouldNavigateToTask = false
    @State private var analysisResult: String = ""
    
    private func parseData() -> ([String: Int], [String: [(String, String)]]) {
        // Parse your response and extract the necessary data
        // For example, you can use regular expressions to extract values from the response string
        
        // Replace this with your actual parsing logic
        let totalMinutesData: [String: Int] = ["Energetic": 270, "Relaxed": 10, "Overwhelmed": 10, "Angry": 20, "Creative": 60, "Tired": 10, "Stressed": 10]
        
        let timeRangesData: [String: [(String, String)]] = ["Energetic": [("15:22", "15:22"), ("15:25", "15:25")], "Relaxed": [("16:10", "16:20")], "Creative": [("16:48", "17:48")]]
        
        return (totalMinutesData, timeRangesData)
    }

    var body: some View {
        ScrollView {
            VStack {
                Text("Analysis of your tasks")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                    .padding(.top, 3)

                Text("It is recommended to create at least 1 positive mood task and 1 negative for a better result")
                    .font(.custom("Courier", size: 17))
                    .foregroundColor(pastelBlueColor)
                    .padding()
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Text(analysisResult)
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(.blue)
                    .padding()
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
                
                let dataPoints: [CGFloat] = [0, 1, 2, 3, 4]
                let line1Data: [CGFloat] = [0, 1, 4, 9, 16]
                let line2Data: [CGFloat] = [0, 2, 3, 1, 4]

                // Draw bar graph for "Total minutes spent in a mood"
                BarGraph(data: parseData().0, title: "Total Minutes Spent in a Mood", legend: "Mood")
                
                LineGraph(dataPoints: dataPoints, linesData: [line1Data, line2Data], lineColors: [.blue, .red])
                    .frame(height: 200)

                // Draw bar graph for "Pleasant Time Ranges for Tasks Completions"
//                LineGraph(data: parseData().1, title: "Pleasant Time Ranges for Tasks Completions", moodNames: Array(parseData().1.keys))
            }
            .padding(.top, 20)
            .onAppear {
                fetchData()
            }
        }
    }
    
    private func fetchData() {
        guard let url = URL(string: "http://localhost:8097/tasks/analyze/\(userId)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                // Handle the error appropriately (show an alert, update UI, etc.)
                return
            }

            guard let data = data else {
                print("No data received")
                // Handle the case where no data is received (show an alert, update UI, etc.)
                return
            }

            if let resultString = String(data: data, encoding: .utf8) {
                // Update analysisResult with the received string
                DispatchQueue.main.async {
                    self.analysisResult = resultString
                }
            } else {
                print("Error converting data to string")
                // Handle the conversion error appropriately (show an alert, update UI, etc.)
            }
        }.resume()
    }
}

struct ResponseModel: Decodable {
    let result: String
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.blue))
            .foregroundColor(.white)
    }
}

struct BarGraph: View {
    let data: [String: Any]?
    let title: String
    let legend: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()

            if let data = data {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { (mood, value) in
                        VStack {
                            Text(mood)
                                .font(.caption)
                                .foregroundColor(.blue)

                            if let intValue = value as? Int {
                                // Bar graph for Int values
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.blue)
                                    .frame(width: 30, height: CGFloat(intValue))
                            } else if let timeRanges = value as? [(String, String)] {
                                // Bar graph for time range values
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.blue)
                                    .frame(width: 30, height: CGFloat(timeRanges.count * 20))
                            }
                        }
                    }
                }
            }

            Text(legend)
                .font(.caption)
                .padding(.bottom, 10)
        }
        .padding()
    }
}

// test line graph
struct LineGraph: View {
    let dataPoints: [CGFloat]
    let linesData: [[CGFloat]]
    let lineColors: [Color]

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<linesData.count) { index in
                Path { path in
                    for i in 0..<dataPoints.count {
                        let x = CGFloat(i) / CGFloat(dataPoints.count - 1) * geometry.size.width
                        let y = (1 - linesData[index][i] / 20) * geometry.size.height
                        let point = CGPoint(x: x, y: y)
                        if i == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(lineColors[index], lineWidth: 2)
            }
        }
    }
}
