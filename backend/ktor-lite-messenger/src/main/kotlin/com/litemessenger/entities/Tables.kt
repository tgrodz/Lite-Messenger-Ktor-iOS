package com.litemessenger.entities

import org.jetbrains.exposed.dao.id.UUIDTable
import org.jetbrains.exposed.sql.ReferenceOption

object UsersTable : UUIDTable("users") {
    val name = varchar("name", 120)
    val email = varchar("email", 120).uniqueIndex()
    val passwordHash = varchar("password_hash", 120)
    val avatarFile = varchar("avatar_file", 255).nullable()
    val abbreviation = varchar("abbreviation", 2)
    val createdAt = long("created_at")
}

object ChatsTable : UUIDTable("chats") {
    val userA = reference("user_a", UsersTable, onDelete = ReferenceOption.CASCADE)
    val userB = reference("user_b", UsersTable, onDelete = ReferenceOption.CASCADE)
}

object MessagesTable : UUIDTable("messages") {
    val chatId = reference("chat_id", ChatsTable, onDelete = ReferenceOption.CASCADE)
    val senderId = reference("sender_id", UsersTable, onDelete = ReferenceOption.CASCADE)
    val recipientId = reference("recipient_id", UsersTable, onDelete = ReferenceOption.CASCADE)
    val content = varchar("content", 1000)
    val createdAt = long("created_at")
}
