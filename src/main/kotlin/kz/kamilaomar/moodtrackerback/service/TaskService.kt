package kz.kamilaomar.moodtrackerback.service

import kz.kamilaomar.moodtrackerback.models.Task
import kz.kamilaomar.moodtrackerback.repository.TaskRepository
import org.springframework.stereotype.Service
import java.util.*

@Service
class TaskService(private val taskRepository: TaskRepository) {

    fun analyzeUserTasks(userId: Long): String {
        val userTasks = taskRepository.findByUserId(userId)

        val (productiveTimes, positiveMoodTimeRanges) = analyzeMoodAndTime(userId)

        val recommendedTasks = recommendTasks(userTasks, productiveTimes.keys.toList())
        val avoidTasks = avoidUncomfortableTasks(userTasks, productiveTimes.keys.toList())

        val exerciseRecommendations = recommendExercises(userTasks)
        val motivationalMessages = generateMotivationalMessages()

        return "Total minutes spent in a mood: $productiveTimes \n" +
                "Pleasant Time Ranges for Tasks Completions:\n $positiveMoodTimeRanges \n" +
                "Recommended Tasks: $recommendedTasks \n" +
                "Avoid Tasks: $avoidTasks \n" +
                "Exercise Recommendations:\n $exerciseRecommendations \n" +
                "$motivationalMessages \n"
    }

    private fun analyzeMoodAndTime(userId: Long): Pair<Map<String, Int>, Map<String, List<String>>> {
        // Retrieve user tasks
        val userTasks = taskRepository.findByUserId(userId)

        // Group tasks by mood and calculate total time for each mood
        val moodTotalTimes = userTasks.groupBy { it.mood }
            .mapValues { entry ->
                val totalMinutes = entry.value.sumBy { task ->
                    calculateMinutesForRangeOfTime(task.startTime, task.finishTime)
                }

                entry.key to totalMinutes // Using entry.key for the mood
            }

        // Determine productive times based on mood total times
        val productiveTimes = mutableMapOf<String, Int>()
        val positiveMoodTimeRanges = mutableMapOf<String, List<String>>()

        for ((mood, totalMinutes) in moodTotalTimes) {
            if (totalMinutes.second > 0) {
                productiveTimes[mood!!] = totalMinutes.second

                // Check for positive moods and add time ranges
                if (isPositiveMood(mood)) {
                    val timeRanges = findPositiveMoodTimeRanges(userTasks, mood)
                    positiveMoodTimeRanges[mood] = timeRanges
                }
            }
        }

        return productiveTimes to positiveMoodTimeRanges
    }

    private fun isPositiveMood(mood: String): Boolean {
        return mood in setOf("Energetic", "Focused", "Determined", "Creative", "Relaxed", "Satisfied")
    }

    private fun findPositiveMoodTimeRanges(tasks: List<Task>, mood: String): List<String> {
        // Find time ranges when the user is in a positive mood
        return tasks.filter { it.mood == mood }
            .map { task ->
                val startTime = task.startTime ?: "00:00"
                val finishTime = task.finishTime ?: "00:00"
                "(${startTime} - ${finishTime})"
            }
    }

    private fun calculateMinutesForRangeOfTime(startTime: String?, finishTime: String?): Int {
        // Convert start and finish times in HH:mm format to minutes
        val startMinutes = startTime?.split(":")?.let { it[0].toInt() * 60 + it[1].toInt() } ?: 0
        val finishMinutes = finishTime?.split(":")?.let { it[0].toInt() * 60 + it[1].toInt() } ?: 0

        return finishMinutes - startMinutes
    }

    private fun calculateMinutes(time: String?): Int {
        // Convert time in HH:mm format to minutes
        return time?.split(":")?.let { it[0].toInt() * 60 + it[1].toInt() } ?: 0
    }

    private fun recommendTasks(tasks: List<Task>, productiveTimes: List<String>): List<String> {
        // Recommend tasks based on productive times and comfortable moods
        return tasks.filter { it.mood in listOf("Energetic", "Focused", "Determined",
            "Creative", "Relaxed", "Satisfied") && calculateMinutes(it.startTime) in 0..720 }
            .map { it.title ?: "Untitled Task" }
    }

    private fun avoidUncomfortableTasks(tasks: List<Task>, productiveTimes: List<String>): List<String> {
        // Identify tasks associated with uncomfortable moods during productive times
        return tasks.filter { it.mood in listOf("Stressed", "Tired", "Stressed",
            "Overwhelmed", "Unmotivated", "Angry") && calculateMinutes(it.startTime) in 0..720 }
            .map { it.title ?: "Untitled Task" }
    }

    fun recommendExercises(tasks: List<Task>): String {
        val recommendations = mutableSetOf<String>()

        for (task in tasks) {
            val mood = task.mood?.lowercase(Locale.getDefault())
            val negativeMoods = listOf("stressed", "tired", "overwhelmed", "unmotivated", "angry")

            if (negativeMoods.contains(mood)) {
                val exercise = when (task.title?.lowercase(Locale.getDefault())) {
                    "work presentation" -> "Work Presentation - Visualization Exercise: Picture yourself confidently delivering the presentation, focusing on success rather than stress."
                    "grocery shopping" -> "Grocery Shopping - Positive Playlist: Create an uplifting playlist to boost your mood and motivation during shopping."
                    "home cleaning" -> "Home Cleaning - 20-Minute Timer: Set a timer for short cleaning bursts to prevent feeling overwhelmed and maintain motivation."
                    "job interview preparation" -> "Job Interview Preparation - Mock Interviews: Practice answering common questions with a friend or in front of a mirror to build confidence."
                    "fitness routine" -> "Fitness Routine - Variety Challenge: Keep motivation high by introducing new exercises or activities into your routine regularly."
                    "meal planning and cooking" -> "Meal Planning and Cooking - Weekly Menu: Plan your meals for the week ahead to reduce stress and make grocery shopping more efficient."
                    "budgeting" -> "Budgeting - Financial Goals: Set specific and achievable financial goals to stay motivated and focused on budgeting."
                    "academic study session" -> "Academic Study Session - Pomodoro Technique: Break study sessions into short, focused intervals with breaks to maintain concentration."
                    "home repairs" -> "Home Repairs - Prioritize and Delegate: Identify and focus on the most crucial repairs, and delegate tasks when possible."
                    "event planning" -> "Event Planning - Task Checklist: Create a detailed checklist for each aspect of the event to stay organized and avoid feeling overwhelmed."
                    else -> ""
                }

                if (exercise.isNotEmpty()) {
                    recommendations.add(exercise)
                }
            }
        }

        return recommendations.joinToString("\n")
    }

    private fun generateMotivationalMessages(): String {
        // Generate random motivational messages
        return """
            You're doing great! Keep pushing forward!
            Success is a journey, not a destination.
            Every small step counts.
        """
    }
}
