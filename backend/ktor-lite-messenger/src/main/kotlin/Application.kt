package com.litemessenger

import com.litemessenger.ktor.configureHTTP
import com.litemessenger.ktor.configureRouting
import com.litemessenger.ktor.configureSecurity
import com.litemessenger.ktor.configureSockets
import com.litemessenger.services.AuthService
import com.litemessenger.services.AvatarService
import com.litemessenger.services.ChatService
import com.litemessenger.services.DatabaseFactory
import com.litemessenger.services.JwtConfig
import com.litemessenger.services.SeedService
import com.litemessenger.services.TokenService
import com.litemessenger.services.UserService
import com.litemessenger.websocket.ChatWebSocketHandler
import com.litemessenger.websocket.ConnectionManager
import io.ktor.server.application.Application
import kotlinx.coroutines.runBlocking
import java.io.File

fun main(args: Array<String>) {
    io.ktor.server.netty.EngineMain.main(args)
}

fun Application.module() {
    configureHTTP()

    val jwtConfig = JwtConfig(
        secret = environment.config.property("jwt.secret").getString(),
        issuer = environment.config.property("jwt.issuer").getString(),
        audience = environment.config.property("jwt.audience").getString(),
        realm = environment.config.property("jwt.realm").getString()
    )
    val storagePath = environment.config.propertyOrNull("storage.avatars")?.getString() ?: "../../storage"
    val avatarService = AvatarService(File(storagePath))

    DatabaseFactory.init()

    val userService = UserService(avatarService)
    val chatService = ChatService(avatarService)
    val tokenService = TokenService(jwtConfig)
    val authService = AuthService(userService, tokenService)
    val seedService = SeedService(userService, chatService)
    runBlocking { seedService.ensureSeeded() }

    val connectionManager = ConnectionManager()
    val socketHandler = ChatWebSocketHandler(connectionManager, tokenService, chatService)

    configureSecurity(tokenService, jwtConfig)
    configureSockets(socketHandler)
    configureRouting(authService, userService, chatService, avatarService, tokenService)
}
