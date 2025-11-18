package com.litemessenger.controllers

import com.litemessenger.domain.ApiMessage
import com.litemessenger.domain.LoginRequest
import com.litemessenger.domain.RegisterRequest
import com.litemessenger.services.AuthService
import io.ktor.http.HttpStatusCode
import io.ktor.server.application.call
import io.ktor.server.request.receive
import io.ktor.server.response.respond
import io.ktor.server.routing.Route
import io.ktor.server.routing.post
import io.ktor.server.routing.route

fun Route.authRoutes(authService: AuthService) {
    route("/auth") {
        post("/register") {
            try {
                val request = call.receive<RegisterRequest>()
                val response = authService.register(request)
                call.respond(HttpStatusCode.Created, response)
            } catch (ex: Exception) {
                call.respond(HttpStatusCode.BadRequest, ApiMessage(ex.message ?: "Unable to register"))
            }
        }
        post("/login") {
            try {
                val request = call.receive<LoginRequest>()
                val response = authService.login(request)
                call.respond(response)
            } catch (ex: Exception) {
                call.respond(HttpStatusCode.Unauthorized, ApiMessage(ex.message ?: "Invalid credentials"))
            }
        }
    }
}
