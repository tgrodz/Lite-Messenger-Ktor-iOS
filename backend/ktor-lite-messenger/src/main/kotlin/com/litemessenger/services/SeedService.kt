package com.litemessenger.services

import java.util.UUID

class SeedService(
    private val userService: UserService,
    private val chatService: ChatService
) {
    suspend fun ensureSeeded() {
        if (userService.countUsers() > 0) return

        val defaults = listOf(
            DefaultUser("User One", "user1@email.com"),
            DefaultUser("User Two", "user2@email.com"),
            DefaultUser("User Three", "user3@email.com"),
            DefaultUser("User Four", "user4@email.com"),
            DefaultUser("User Five", "user5@email.com")
        )

        val created = defaults.associate { user ->
            val profile = userService.createUser(user.name, user.email, DEFAULT_PASSWORD)
            user.name to UUID.fromString(profile.id)
        }

        val scripts = listOf(
            SeedConversation(
                participantA = "User One",
                participantB = "User Two",
                lines = listOf(
                    SeedLine("User One", "hello"),
                    SeedLine("User Two", "hello, how are you"),
                    SeedLine("User One", "I am great")
                )
            ),
            SeedConversation(
                participantA = "User Three",
                participantB = "User Four",
                lines = listOf(
                    SeedLine("User Three", "hey there"),
                    SeedLine("User Four", "hello, how are you"),
                    SeedLine("User Three", "I am great")
                )
            ),
            SeedConversation(
                participantA = "User Five",
                participantB = "User One",
                lines = listOf(
                    SeedLine("User Five", "hello"),
                    SeedLine("User One", "hello, how are you"),
                    SeedLine("User Five", "I am great")
                )
            )
        )

        scripts.forEach { conversation ->
            val userA = created[conversation.participantA]
            val userB = created[conversation.participantB]
            if (userA != null && userB != null) {
                val chat = chatService.ensureChat(userA, userB)
                conversation.lines.forEach { line ->
                    val sender = created[line.sender]
                    if (sender != null) {
                        chatService.addMessage(chat.id, sender, line.message)
                    }
                }
            }
        }
    }

    private data class DefaultUser(val name: String, val email: String)

    private data class SeedConversation(
        val participantA: String,
        val participantB: String,
        val lines: List<SeedLine>
    )

    private data class SeedLine(val sender: String, val message: String)

    companion object {
        private const val DEFAULT_PASSWORD = "123456"
    }
}
