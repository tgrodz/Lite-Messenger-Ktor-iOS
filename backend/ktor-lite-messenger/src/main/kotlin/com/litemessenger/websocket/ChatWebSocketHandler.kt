package com.litemessenger.websocket

import com.litemessenger.services.ChatService
import com.litemessenger.services.TokenService
import io.ktor.websocket.CloseReason
import io.ktor.server.websocket.DefaultWebSocketServerSession
import io.ktor.websocket.Frame
import io.ktor.websocket.close
import io.ktor.websocket.readText
import io.ktor.websocket.send
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.util.UUID

class ChatWebSocketHandler(
    private val connectionManager: ConnectionManager,
    private val tokenService: TokenService,
    private val chatService: ChatService
) {
    private val json = Json { ignoreUnknownKeys = true }

    suspend fun handle(session: DefaultWebSocketServerSession) {
        val token = session.call.request.queryParameters["token"]
        val userId = token?.let { tokenService.extractUserId(it) }
        if (userId == null) {
            session.close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, "Missing or invalid token"))
            return
        }
        connectionManager.connect(userId, session)
        session.send(json.encodeToString(SocketServerMessage(type = "status", message = "connected")))
        try {
            for (frame in session.incoming) {
                when (frame) {
                    is Frame.Text -> handleIncoming(frame.readText(), userId)
                    else -> {}
                }
            }
        } finally {
            connectionManager.disconnect(userId, session)
        }
    }

    private suspend fun handleIncoming(raw: String, userId: UUID) {
        val message = runCatching { json.decodeFromString<SocketClientMessage>(raw) }.getOrNull()
        if (message == null) {
            emit(userId, SocketServerMessage(type = "error", message = "Invalid payload"))
            return
        }
        when (message.action.lowercase()) {
            "send_message" -> handleSendMessage(message, userId)
            else -> emit(userId, SocketServerMessage(type = "error", message = "Unknown action ${message.action}"))
        }
    }

    private suspend fun handleSendMessage(incoming: SocketClientMessage, userId: UUID) {
        val resolvedChatId = incoming.chatId?.let { parseUuid(it) }
        val resolvedRecipient = incoming.recipientId?.let { parseUuid(it) }
        val chatId = resolvedChatId ?: run {
            if (resolvedRecipient == null) {
                emit(userId, SocketServerMessage(type = "error", message = "Recipient required"))
                return
            }
            val created = chatService.ensureChat(userId, resolvedRecipient)
            created.id
        }
        val payload = try {
            chatService.addMessage(chatId, userId, incoming.content.orEmpty())
        } catch (ex: Exception) {
            emit(userId, SocketServerMessage(type = "error", message = ex.message ?: "Unable to send"))
            return
        }
        val recipients = setOfNotNull(
            runCatching { UUID.fromString(payload.senderId) }.getOrNull(),
            runCatching { UUID.fromString(payload.recipientId) }.getOrNull()
        )
        val response = json.encodeToString(SocketServerMessage(type = "message", payload = payload))
        recipients.forEach { recipient ->
            connectionManager.sendTo(recipient, response)
        }
    }

    private fun parseUuid(value: String): UUID? = runCatching { UUID.fromString(value) }.getOrNull()

    private suspend fun emit(userId: UUID, message: SocketServerMessage) {
        val payload = json.encodeToString(message)
        connectionManager.sendTo(userId, payload)
    }

    private fun <T> setOfNotNull(vararg values: T?): Set<T> = buildSet {
        values.forEach { value ->
            if (value != null) add(value)
        }
    }
}
