package com.litemessenger.websocket

import io.ktor.websocket.CloseReason
import io.ktor.websocket.Frame
import io.ktor.websocket.WebSocketSession
import io.ktor.websocket.close
import io.ktor.websocket.send
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

class ConnectionManager {
    private val sessions: MutableMap<UUID, MutableSet<WebSocketSession>> = ConcurrentHashMap()

    fun connect(userId: UUID, session: WebSocketSession) {
        sessions.compute(userId) { _, existing ->
            val set = existing ?: ConcurrentHashMap.newKeySet()
            set.add(session)
            set
        }
    }

    fun disconnect(userId: UUID, session: WebSocketSession) {
        sessions[userId]?.let { set ->
            set.remove(session)
            if (set.isEmpty()) {
                sessions.remove(userId)
            }
        }
    }

    suspend fun sendTo(userId: UUID, payload: String) {
        sessions[userId]?.forEach { session ->
            runCatching { session.send(Frame.Text(payload)) }
        }
    }

    suspend fun broadcastTo(userIds: Set<UUID>, payload: String) {
        userIds.forEach { sendTo(it, payload) }
    }

    suspend fun closeAll() {
        sessions.forEach { (_, set) ->
            set.forEach { session ->
                session.close(CloseReason(CloseReason.Codes.NORMAL, "Server shutting down"))
            }
        }
        sessions.clear()
    }
}
