package com.litemessenger.ktor

import com.litemessenger.controllers.authRoutes
import com.litemessenger.controllers.chatRoutes
import com.litemessenger.controllers.userRoutes
import com.litemessenger.services.AuthService
import com.litemessenger.services.AvatarService
import com.litemessenger.services.ChatService
import com.litemessenger.services.TokenService
import com.litemessenger.services.UserService
import io.ktor.http.ContentType
import io.ktor.server.application.Application
import io.ktor.server.application.call
import io.ktor.server.auth.authenticate
import io.ktor.server.response.respondText
import io.ktor.server.routing.get
import io.ktor.server.routing.route
import io.ktor.server.routing.routing
import io.ktor.server.http.content.staticFiles

fun Application.configureRouting(
    authService: AuthService,
    userService: UserService,
    chatService: ChatService,
    avatarService: AvatarService,
    tokenService: TokenService
) {
    routing {
        get("/") {
            call.respondText("Lite Messenger backend", contentType = ContentType.Text.Plain)
        }

        staticFiles("/avatars", avatarService.storageRoot())

        route("/api") {
            authRoutes(authService)
            authenticate("auth-jwt") {
                userRoutes(userService, avatarService, tokenService)
                chatRoutes(chatService, tokenService)
            }
        }
    }
}
