package kz.kamilaomar.moodtrackerback.controller

import kz.kamilaomar.moodtrackerback.models.Task
import kz.kamilaomar.moodtrackerback.repository.TaskRepository
import kz.kamilaomar.moodtrackerback.service.UserService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
class TaskController(
    private val taskRepository: TaskRepository,
    private val userService: UserService
) {

    @GetMapping("/tasks")
    fun getAllTasks(): List<Task> = taskRepository.findAll()

    @PostMapping("/tasks")
    fun createTask(@RequestBody task: Task): ResponseEntity<String> {
        taskRepository.save(task)

        return ResponseEntity.ok("Task successfully created")
    }

    @PutMapping("/tasks/{id}")
    fun updateTask(@PathVariable id: Long, @RequestBody updatedTask: Task): ResponseEntity<Task> {
        return taskRepository.findById(id).map { existingTask ->
            val updated = existingTask.copy(
                title = updatedTask.title,
                description = updatedTask.description,
                priority = updatedTask.priority
            )
            ResponseEntity.ok().body(taskRepository.save(updated))
        }.orElse(ResponseEntity.notFound().build())
    }

    @DeleteMapping("/{id}")
    fun deleteTask(@PathVariable id: Long): ResponseEntity<Void> {
        return taskRepository.findById(id).map { task ->
            taskRepository.delete(task)
            ResponseEntity<Void>(HttpStatus.OK)
        }.orElse(ResponseEntity.notFound().build())
    }
}
