package com.litemessenger.ktor

import com.litemessenger.websocket.ChatWebSocketHandler
import io.ktor.server.application.Application
import io.ktor.server.routing.routing
import io.ktor.server.websocket.webSocket

fun Application.configureSockets(handler: ChatWebSocketHandler) {
    routing {
        webSocket("/ws/chat") {
            handler.handle(this)
        }
    }
}
