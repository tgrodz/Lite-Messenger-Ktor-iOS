package com.litemessenger.websocket

import com.litemessenger.domain.MessagePayload
import kotlinx.serialization.Serializable

@Serializable
data class SocketClientMessage(
    val action: String,
    val chatId: String? = null,
    val recipientId: String? = null,
    val content: String? = null
)

@Serializable
data class SocketServerMessage(
    val type: String,
    val payload: MessagePayload? = null,
    val message: String? = null
)
