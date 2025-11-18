package com.litemessenger.domain

import kotlinx.serialization.Serializable

@Serializable
data class UserProfile(
    val id: String,
    val name: String,
    val email: String,
    val avatarUrl: String? = null,
    val abbreviation: String
)

@Serializable
data class UserPreview(
    val id: String,
    val name: String,
    val abbreviation: String,
    val avatarUrl: String? = null,
    val email: String? = null
)

@Serializable
data class AuthResponse(
    val token: String,
    val user: UserProfile
)

@Serializable
data class LoginRequest(
    val email: String,
    val password: String
)

@Serializable
data class RegisterRequest(
    val name: String,
    val email: String,
    val password: String
)

@Serializable
data class ChatSummary(
    val chatId: String,
    val contact: UserPreview,
    val lastMessage: MessagePayload? = null
)

@Serializable
data class MessagePayload(
    val id: String,
    val chatId: String,
    val senderId: String,
    val recipientId: String,
    val senderName: String,
    val content: String,
    val timestamp: Long,
    val senderAvatarUrl: String? = null
)

@Serializable
data class StartChatRequest(
    val participantId: String
)

@Serializable
data class ApiMessage(
    val message: String
)
