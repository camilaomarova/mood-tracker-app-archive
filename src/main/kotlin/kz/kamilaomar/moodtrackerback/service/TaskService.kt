package kz.kamilaomar.moodtrackerback.service

import kz.kamilaomar.moodtrackerback.models.Task
import kz.kamilaomar.moodtrackerback.repository.TaskRepository
import org.springframework.stereotype.Service

@Service
class TaskService(private val taskRepository: TaskRepository) {

    fun analyzeUserTasks(userId: Long): String {
        val userTasks = taskRepository.findByUserId(userId)

        val productiveTimes = analyzeMoodAndTime(userTasks)
        val recommendedTasks = recommendTasks(userTasks, productiveTimes)
        val avoidTasks = avoidUncomfortableTasks(userTasks, productiveTimes)
        val exerciseRecommendations = recommendExercises(userTasks)
        val motivationalMessages = generateMotivationalMessages()

        // Print or use the results as needed
        println("Productive Times: $productiveTimes")
        println("Recommended Tasks: $recommendedTasks")
        println("Avoid Tasks: $avoidTasks")
        println("Exercise Recommendations: $exerciseRecommendations")
        println("Motivational Messages: $motivationalMessages")

        return "Productive Times: $productiveTimes \n" +
                "Recommended Tasks: $recommendedTasks \n" +
                "Avoid Tasks: $avoidTasks \n" +
                "Exercise Recommendations: $exerciseRecommendations \n" +
                "Motivational Messages: $motivationalMessages \n"
    }

    private fun analyzeMoodAndTime(tasks: List<Task>): List<String> {
        // Group tasks by mood and calculate average time for each mood
        val moodAverageTimes = tasks.groupBy { it.mood }
            .mapValues { entry ->
                val totalMinutes = entry.value.mapNotNull { calculateMinutes(it.time) }.sum()
                val averageMinutes = if (entry.value.isNotEmpty()) totalMinutes / entry.value.size else 0
                Pair(entry.key ?: "", averageMinutes) // Ensure a default value for the key
            }

        // Determine productive times based on mood average times
        return moodAverageTimes
            .filter { it.value.second > 0 }
            .toList()
            .sortedByDescending { it.second.second }
            .map { it.first!! }
    }

    private fun calculateMinutes(time: String?): Int {
        // Convert time in HH:mm format to minutes
        return time?.split(":")?.let { it[0].toInt() * 60 + it[1].toInt() } ?: 0
    }

    private fun recommendTasks(tasks: List<Task>, productiveTimes: List<String>): List<String> {
        // Recommend tasks based on productive times and comfortable moods
        return tasks.filter { it.mood in listOf("Energetic", "Focused", "Determined") && calculateMinutes(it.time) in 0..720 }
            .map { it.title ?: "Untitled Task" }
    }

    private fun avoidUncomfortableTasks(tasks: List<Task>, productiveTimes: List<String>): List<String> {
        // Identify tasks associated with uncomfortable moods during productive times
        return tasks.filter { it.mood in listOf("Stressed", "Tired") && calculateMinutes(it.time) in 0..720 }
            .map { it.title ?: "Untitled Task" }
    }

    private fun recommendExercises(tasks: List<Task>): List<String> {
        // Recommend exercises based on uncomfortable moods
        return tasks.filter { it.mood in listOf("Stressed", "Tired") && calculateMinutes(it.time) in 0..720 }
            .map { "Exercise for mood improvement: ${it.title}" }
    }

    private fun generateMotivationalMessages(): List<String> {
        // Generate random motivational messages
        return listOf(
            "You're doing great!",
            "Keep pushing forward!",
            "Success is a journey, not a destination.",
            "Believe in yourself!",
            "Every small step counts."
        )
    }
}
