package com.litemessenger.controllers

import com.litemessenger.domain.ApiMessage
import com.litemessenger.domain.StartChatRequest
import com.litemessenger.services.ChatService
import com.litemessenger.services.TokenService
import io.ktor.http.HttpStatusCode
import io.ktor.server.application.call
import io.ktor.server.auth.jwt.JWTPrincipal
import io.ktor.server.auth.principal
import io.ktor.server.request.receive
import io.ktor.server.response.respond
import io.ktor.server.routing.Route
import io.ktor.server.routing.get
import io.ktor.server.routing.post
import io.ktor.server.routing.route
import java.util.UUID

fun Route.chatRoutes(
    chatService: ChatService,
    tokenService: TokenService
) {
    route("/chats") {
        get {
            val principal = call.principal<JWTPrincipal>()
            val userId = principal?.let { tokenService.extractUserId(it) }
            if (userId == null) {
                call.respond(HttpStatusCode.Unauthorized)
                return@get
            }
            val chats = chatService.listChats(userId)
            call.respond(chats)
        }

        get("/{id}/messages") {
            val principal = call.principal<JWTPrincipal>()
            val userId = principal?.let { tokenService.extractUserId(it) }
            if (userId == null) {
                call.respond(HttpStatusCode.Unauthorized)
                return@get
            }
            val chatId = call.parameters["id"]?.let { runCatching { UUID.fromString(it) }.getOrNull() }
            if (chatId == null) {
                call.respond(HttpStatusCode.BadRequest, ApiMessage("Invalid chat id"))
                return@get
            }
            val messages = chatService.getMessages(chatId, userId)
            call.respond(messages)
        }

        post("/start") {
            val principal = call.principal<JWTPrincipal>()
            val userId = principal?.let { tokenService.extractUserId(it) }
            if (userId == null) {
                call.respond(HttpStatusCode.Unauthorized)
                return@post
            }
            val body = call.receive<StartChatRequest>()
            val participantId = runCatching { UUID.fromString(body.participantId) }.getOrNull()
            if (participantId == null) {
                call.respond(HttpStatusCode.BadRequest, ApiMessage("Invalid participant id"))
                return@post
            }
            val chat = chatService.ensureChat(userId, participantId)
            val summary = chatService.listChats(userId).firstOrNull { it.chatId == chat.id.toString() }
            if (summary == null) {
                call.respond(HttpStatusCode.InternalServerError, ApiMessage("Chat could not be loaded"))
            } else {
                call.respond(HttpStatusCode.Created, summary)
            }
        }
    }
}
