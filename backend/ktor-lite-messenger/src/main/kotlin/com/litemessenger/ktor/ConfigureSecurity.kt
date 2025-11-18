package com.litemessenger.ktor

import com.litemessenger.domain.ApiMessage
import com.litemessenger.services.JwtConfig
import com.litemessenger.services.TokenService
import io.ktor.http.HttpStatusCode
import io.ktor.server.application.Application
import io.ktor.server.application.install
import io.ktor.server.auth.Authentication
import io.ktor.server.auth.jwt.JWTPrincipal
import io.ktor.server.auth.jwt.jwt
import io.ktor.server.response.respond

fun Application.configureSecurity(tokenService: TokenService, jwtConfig: JwtConfig) {
    install(Authentication) {
        jwt("auth-jwt") {
            realm = jwtConfig.realm
            verifier(tokenService.verifier)
            validate { credential ->
                if (credential.payload.getClaim("id").asString() != null) JWTPrincipal(credential.payload) else null
            }
            challenge { _, _ ->
                call.respond(HttpStatusCode.Unauthorized, ApiMessage("Invalid or expired token"))
            }
        }
    }
}
