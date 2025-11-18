package com.litemessenger.services

import com.litemessenger.domain.ChatSummary
import com.litemessenger.domain.MessagePayload
import com.litemessenger.domain.UserPreview
import com.litemessenger.entities.ChatsTable
import com.litemessenger.entities.MessagesTable
import com.litemessenger.entities.UsersTable
import org.jetbrains.exposed.sql.ResultRow
import org.jetbrains.exposed.sql.SortOrder
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.insertAndGetId
import org.jetbrains.exposed.sql.or
import org.jetbrains.exposed.sql.select
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import java.util.UUID

class ChatService(private val avatarService: AvatarService) {

    suspend fun ensureChat(userA: UUID, userB: UUID): ChatRecord = DatabaseFactory.dbQuery {
        require(userA != userB) { "Cannot start a chat with yourself" }
        val existing = findChatRecord(userA, userB)
        existing ?: run {
            requireUserExists(userA)
            requireUserExists(userB)
            val newId = ChatsTable.insertAndGetId {
                it[ChatsTable.userA] = userA
                it[ChatsTable.userB] = userB
            }.value
            ChatRecord(newId, userA, userB)
        }
    }

    suspend fun listChats(forUser: UUID): List<ChatSummary> = DatabaseFactory.dbQuery {
        ChatsTable.select { (ChatsTable.userA eq forUser) or (ChatsTable.userB eq forUser) }
            .map { row ->
                val record = row.toChatRecord()
                val contactId = if (record.userA == forUser) record.userB else record.userA
                val contactPreview = fetchPreview(contactId)
                    ?: UserPreview(contactId.toString(), "Unknown", "UN", null, null)
                val lastMessage = findLastMessage(record.id)
                ChatSummary(
                    chatId = record.id.toString(),
                    contact = contactPreview,
                    lastMessage = lastMessage
                )
            }
    }

    suspend fun getMessages(chatId: UUID, requester: UUID): List<MessagePayload> = DatabaseFactory.dbQuery {
        val chat = findChatRecord(chatId) ?: throw IllegalArgumentException("Chat not found")
        ensureParticipant(chat, requester)
        MessagesTable.select { MessagesTable.chatId eq chat.id }
            .orderBy(MessagesTable.createdAt to SortOrder.ASC)
            .map { mapMessageRow(it) }
    }

    suspend fun addMessage(chatId: UUID, senderId: UUID, content: String): MessagePayload = DatabaseFactory.dbQuery {
        val chat = findChatRecord(chatId) ?: throw IllegalArgumentException("Chat not found")
        ensureParticipant(chat, senderId)
        val recipient = if (chat.userA == senderId) chat.userB else chat.userA
        val sanitized = content.trim()
        require(sanitized.isNotEmpty()) { "Message cannot be empty" }
        val newId = MessagesTable.insertAndGetId {
            it[MessagesTable.chatId] = chat.id
            it[MessagesTable.senderId] = senderId
            it[MessagesTable.recipientId] = recipient
            it[MessagesTable.content] = sanitized
            it[MessagesTable.createdAt] = System.currentTimeMillis()
        }.value
        val row = MessagesTable.select { MessagesTable.id eq newId }.single()
        mapMessageRow(row)
    }

    private fun ResultRow.toChatRecord(): ChatRecord = ChatRecord(
        id = this[ChatsTable.id].value,
        userA = this[ChatsTable.userA].value,
        userB = this[ChatsTable.userB].value
    )

    private fun findChatRecord(userA: UUID, userB: UUID): ChatRecord? =
        ChatsTable.select {
            ((ChatsTable.userA eq userA) and (ChatsTable.userB eq userB)) or
                ((ChatsTable.userA eq userB) and (ChatsTable.userB eq userA))
        }.singleOrNull()?.toChatRecord()

    private fun findChatRecord(chatId: UUID): ChatRecord? =
        ChatsTable.select { ChatsTable.id eq chatId }.singleOrNull()?.toChatRecord()

    private fun ensureParticipant(chat: ChatRecord, userId: UUID) {
        require(chat.userA == userId || chat.userB == userId) { "You are not part of this chat" }
    }

    private fun requireUserExists(userId: UUID) {
        val exists = UsersTable.select { UsersTable.id eq userId }.count() > 0
        require(exists) { "User does not exist" }
    }

    private fun fetchPreview(userId: UUID): UserPreview? =
        UsersTable.select { UsersTable.id eq userId }.singleOrNull()?.let { row ->
            UserPreview(
                id = userId.toString(),
                name = row[UsersTable.name],
                abbreviation = row[UsersTable.abbreviation],
                avatarUrl = avatarService.resolvePublicUrl(row[UsersTable.avatarFile]),
                email = row[UsersTable.email]
            )
        }

    private fun findLastMessage(chatId: UUID): MessagePayload? =
        MessagesTable.select { MessagesTable.chatId eq chatId }
            .orderBy(MessagesTable.createdAt to SortOrder.DESC)
            .limit(1)
            .singleOrNull()
            ?.let { mapMessageRow(it) }

    private fun mapMessageRow(row: ResultRow): MessagePayload {
        val senderId = row[MessagesTable.senderId].value
        val recipientId = row[MessagesTable.recipientId].value
        val senderRow = UsersTable.select { UsersTable.id eq senderId }.singleOrNull()
        val senderName = senderRow?.get(UsersTable.name) ?: "Unknown"
        val avatar = avatarService.resolvePublicUrl(senderRow?.get(UsersTable.avatarFile))
        return MessagePayload(
            id = row[MessagesTable.id].value.toString(),
            chatId = row[MessagesTable.chatId].value.toString(),
            senderId = senderId.toString(),
            recipientId = recipientId.toString(),
            senderName = senderName,
            content = row[MessagesTable.content],
            timestamp = row[MessagesTable.createdAt],
            senderAvatarUrl = avatar
        )
    }

    data class ChatRecord(
        val id: UUID,
        val userA: UUID,
        val userB: UUID
    )
}
