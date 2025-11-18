package com.litemessenger.controllers

import com.litemessenger.domain.ApiMessage
import com.litemessenger.services.AvatarService
import com.litemessenger.services.TokenService
import com.litemessenger.services.UserService
import io.ktor.http.HttpStatusCode
import io.ktor.http.content.PartData
import io.ktor.http.content.streamProvider
import io.ktor.server.application.call
import io.ktor.server.auth.jwt.JWTPrincipal
import io.ktor.server.auth.principal
import io.ktor.server.request.receiveMultipart
import io.ktor.server.response.respond
import io.ktor.server.routing.Route
import io.ktor.server.routing.get
import io.ktor.server.routing.post
import io.ktor.server.routing.route
import java.util.UUID

fun Route.userRoutes(
    userService: UserService,
    avatarService: AvatarService,
    tokenService: TokenService
) {
    route("/users") {
        get("/me") {
            val principal = call.principal<JWTPrincipal>()
            val userId = principal?.let { tokenService.extractUserId(it) }
            if (userId == null) {
                call.respond(HttpStatusCode.Unauthorized)
                return@get
            }
            val profile = userService.findUserProfile(userId)
            if (profile == null) {
                call.respond(HttpStatusCode.NotFound)
            } else {
                call.respond(profile)
            }
        }

        get("/{id}") {
            val idParam = call.parameters["id"]
            val requestedId = idParam?.let { runCatching { UUID.fromString(it) }.getOrNull() }
            if (requestedId == null) {
                call.respond(HttpStatusCode.BadRequest, ApiMessage("Invalid user id"))
                return@get
            }
            val profile = userService.findUserProfile(requestedId)
            if (profile == null) {
                call.respond(HttpStatusCode.NotFound, ApiMessage("User not found"))
            } else {
                call.respond(profile)
            }
        }

        get("/search") {
            val principal = call.principal<JWTPrincipal>()
            val userId = principal?.let { tokenService.extractUserId(it) }
            if (userId == null) {
                call.respond(HttpStatusCode.Unauthorized)
                return@get
            }
            val query = call.request.queryParameters["q"] ?: ""
            val results = userService.searchUsers(userId, query)
            call.respond(results)
        }

        post("/avatar") {
            val principal = call.principal<JWTPrincipal>()
            val userId = principal?.let { tokenService.extractUserId(it) }
            if (userId == null) {
                call.respond(HttpStatusCode.Unauthorized)
                return@post
            }
            val multipart = call.receiveMultipart()
            var avatarBytes: ByteArray? = null
            var fileName: String? = null
            var part = multipart.readPart()
            while (part != null) {
                when (part) {
                    is PartData.FileItem -> {
                        avatarBytes = part.streamProvider().readBytes()
                        fileName = part.originalFileName
                    }
                    else -> {}
                }
                part.dispose()
                part = multipart.readPart()
            }
            if (avatarBytes == null) {
                call.respond(HttpStatusCode.BadRequest, ApiMessage("Avatar file missing"))
                return@post
            }
            val storedName = avatarService.saveAvatar(avatarBytes!!, fileName)
            val profile = userService.updateAvatar(userId, storedName)
            if (profile == null) {
                call.respond(HttpStatusCode.InternalServerError, ApiMessage("Unable to update avatar"))
            } else {
                call.respond(profile)
            }
        }
    }
}
