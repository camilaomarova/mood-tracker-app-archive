import SwiftUI
import Charts

struct AnalyzeView: View {
    let userId: String
    let bearerToken: String
    
    init(userId: String, bearerToken: String) {
        self.userId = userId
        self.bearerToken = bearerToken
    }

    let pastelBlueColor = Color(red: 0.6, green: 0.8, blue: 1.0)
    
    private var timeRanges: [(String, String)] = []
    private var mood: String = ""

    @State private var shouldNavigateToTask = false
    @State private var totalMinutesData: [String: Int] = [:]
    @State private var timeRangesData: [String: [(String, String)]] = [:]
    @State private var analysisResult: String = ""
    
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
                    .foregroundColor(.black)
                    .padding()
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
                // Draw bar graph for "Total minutes spent in a mood"
                SimpleLineChartView(totalMinutesData: totalMinutesData)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 250)
                
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()

                // Draw bar graph for "Total minutes spent in a mood"
                BarGraph(data: totalMinutesData, legend: "Mood", title: "")

                // Draw bar graph for "Pleasant Time Ranges for Tasks Completions"
                BarGraph(data: timeRangesData, legend: "Mood Time Range", title: "Pleasant Time Ranges for Tasks Completions")
                
                // Integrate the TimeRangesView here
                ClockView(timeRangesData: timeRangesData)
                    .padding()
                    .frame(width: 240, height: 240)
                
                Spacer()
                Spacer()
                Spacer()
            }
            .padding(.top, 20)
            .onAppear {
                fetchData()
            }
        }
    }
    
    private func angle(for time: String) -> Angle {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard let date = dateFormatter.date(from: time) else {
            return Angle(degrees: 0)
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)

        guard let hour = components.hour, let minute = components.minute else {
            return Angle(degrees: 0)
        }

        // Calculate the angle based on hour and minute components
        let hourAngle = Angle(degrees: Double((hour % 12) * 30 + minute / 2))

        return hourAngle
    }

    private func labelPosition(for angle: Double, in radius: CGFloat) -> CGPoint {
        let smallerRadius = radius * 0.4 // Adjust the scale factor (0.4) as needed
        let radians = angle * .pi / 180
        let x = smallerRadius * cos(CGFloat(radians))
        let y = smallerRadius * sin(CGFloat(radians))
        let centerX = CGFloat(200) / 2 // Center of the circle
        let centerY = CGFloat(200) / 2 // Center of the circle

        // Apply the scale factor only to the x-coordinate of the numbers
        let mirroredX = -x

        return CGPoint(x: centerX + mirroredX, y: centerY + y)
    }

    private func color(for mood: String) -> Color {
        // Assign a unique color for each mood or use a predefined color scheme
        // Modify this method based on your color preferences
        switch mood {
        case "Energetic":
            return .red
        case "Relaxed":
            return .green
        case "Creative":
            return .yellow
        default:
            return .gray
        }
    }

    private func fetchData() {
        // Data fetching logic
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
                
                // Example data for testing
                let extractedString = """
                {"totalMinutesData": {"Energetic": 270, "Relaxed": 10, "Overwhelmed": 10, "Angry": 20, "Creative": 60, "Tired": 10, "Stressed": 10},
                 "timeRangesData": {"Energetic": [("15:22", "16:22")], "Relaxed": [("16:10", "16:20")], "Creative": [("16:48", "17:48")]}}
            """
                let (totalMinutesData, timeRangesData) = parseData(from: extractedString)
                
                DispatchQueue.main.async {
                    self.totalMinutesData = totalMinutesData
                    self.timeRangesData = timeRangesData
                    self.analysisResult = resultString
                }
            }
        }.resume()
    }
    
    private func parseData(from response: String) -> ([String: Int], [String: [(String, String)]]) {
        // Parse your response and extract the necessary data
        // For example, you can use regular expressions to extract values from the response string
        let totalMinutesData: [String: Int] = ["Energetic": 270, "Relaxed": 10, "Overwhelmed": 10, "Angry": 20, "Creative": 60, "Tired": 10, "Stressed": 10]

        let timeRangesData: [String: [(String, String)]] = ["Energetic": [("15:22", "15:22"), ("15:25", "15:25")], "Relaxed": [("16:10", "16:20")], "Creative": [("16:48", "17:48")]]

        return (totalMinutesData, timeRangesData)
    }
}

struct SimpleLineChartView: View {
    let totalMinutesData: [String: Int]

    var body: some View {
        VStack {
            Text("Total Minutes Spent in a Mood")
                .font(.headline)
                .padding()

            Chart {
                ForEach(totalMinutesData.sorted(by: { $0.key < $1.key }), id: \.key) { (mood, value) in
                    LineMark(x: .value(mood, mood), y: .value("Total Minutes", Double(value)))
                        .foregroundStyle(Color.blue)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                }
            }
            .chartXScale(range: .plotDimension(padding: 20.0))
            .chartXAxis {
                AxisMarks(preset: .aligned, position: .top, values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.day().weekday(.narrow))
                }
            }
            .chartPlotStyle { plotArea in
                plotArea.frame(maxWidth: .infinity, minHeight: 250.0, maxHeight: 250.0)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }

            // Legend as a list
            VStack(alignment: .leading, spacing: 10) {
                ForEach(totalMinutesData.sorted(by: { $0.key < $1.key }), id: \.key) { (mood, _) in
                    LegendItem(color: Color.blue, label: mood)
                }
            }
            .padding(.bottom, 10)
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 5)
                .fill(color)
                .frame(width: 15, height: 15)
            Text(label)
                .font(.caption)
                .lineLimit(1) // Set line limit to 1 to prevent truncation
                .minimumScaleFactor(0.5) // Adjust the minimum scale factor as needed
        }
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
    let legend: String
    let title: String

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

struct ClockView: View {
    let timeRangesData: [String: [(String, String)]]

    var body: some View {
        VStack {
            Text("Pleasant Time Ranges on Clock")
                .font(.headline)
                .padding()
            
            ZStack {
                // Rotate the entire clock by -90 degrees
                ForEach(timeRangesData.sorted(by: { $0.key < $1.key }), id: \.key) { (mood, ranges) in
                    ForEach(ranges.indices, id: \.self) { index in
                        let range = ranges[index]
                        if mood == "Relaxed" {
                            if index == 0 {
                                // Draw the pie slice for "Relaxed" in yellow for the specified time range
                                PieSlice(startAngle: angle(for: range.0),
                                         endAngle: angle(for: range.1),
                                         clockwise: true)
                                    .foregroundColor(.yellow)
                            }
                        } else if mood == "Creative" {
                            // Draw the pie slice for "Creative" in green for all ranges
                            PieSlice(startAngle: angle(for: range.0),
                                     endAngle: angle(for: range.1),
                                     clockwise: true)
                                .foregroundColor(.green)
                                .overlay(
                                    Text(String(mood.prefix(3)))
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(-90))
                                        .position(labelPosition(for: angle(for: range.0), in: 100))
                                )
                        } else {
                            // Draw other moods in their respective colors
                            PieSlice(startAngle: angle(for: range.0),
                                     endAngle: angle(for: range.1),
                                     clockwise: true)
                                .foregroundColor(color(for: mood))
                                .overlay(
                                    Text(String(mood.prefix(3)))
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(-90))
                                        .position(labelPosition(for: angle(for: range.0), in: 100))
                                )
                        }
                    }
                }

                // Numbers should be visually rotated but not their places
                ForEach(1..<13) { hour in
                    Text("\(hour)")
                        .font(.system(size: 18).weight(.bold)) // Adjust the font size as needed
                        .rotationEffect(.degrees(90)) // Rotate the number text visually
                        .position(labelPosition(for: Double(hour) * 30, in: 90)) // Adjust the radius as needed
                }
            }
            .frame(width: 240, height: 240)
            .rotationEffect(.degrees(-90)) // Rotate the entire clock back to its original position
        }
        .padding()
    }

    private func angle(for time: String) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard let date = dateFormatter.date(from: time) else {
            return 0
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)

        guard let hour = components.hour, let minute = components.minute else {
            return 0
        }

        return Double((hour % 12) * 30 + minute / 2)
    }

    private func color(for mood: String) -> Color {
        switch mood {
        case "Energetic":
            return .red
        case "Relaxed":
            return .green
        case "Creative":
            return .yellow
        default:
            return .gray
        }
    }

    private func labelPosition(for angle: Double, in radius: CGFloat) -> CGPoint {
        let radians = angle * .pi / 180
        let x = radius * cos(CGFloat(radians))
        let y = radius * sin(CGFloat(radians))
        let centerX = CGFloat(120) // Center of the clock
        let centerY = CGFloat(120) // Center of the clock

        return CGPoint(x: centerX + x, y: centerY + y)
    }
}

struct PieSlice: Shape {
    var startAngle: Double
    var endAngle: Double
    var clockwise: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), clockwise: clockwise)
        path.closeSubpath()

        return path
    }
}
