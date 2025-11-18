package com.litemessenger.services

import com.auth0.jwt.JWT
import com.auth0.jwt.JWTVerifier
import com.auth0.jwt.algorithms.Algorithm
import io.ktor.server.auth.jwt.JWTPrincipal
import java.util.Date
import java.util.UUID

data class JwtConfig(
    val secret: String,
    val issuer: String,
    val audience: String,
    val realm: String
)

class TokenService(private val config: JwtConfig) {
    private val algorithm = Algorithm.HMAC256(config.secret)
    val verifier: JWTVerifier = JWT
        .require(algorithm)
        .withAudience(config.audience)
        .withIssuer(config.issuer)
        .build()

    fun generate(userId: UUID, email: String): String = JWT.create()
        .withSubject("Authentication")
        .withIssuer(config.issuer)
        .withAudience(config.audience)
        .withClaim("id", userId.toString())
        .withClaim("email", email)
        .withExpiresAt(Date(System.currentTimeMillis() + TOKEN_VALIDITY))
        .sign(algorithm)

    fun extractUserId(principal: JWTPrincipal): UUID? =
        principal.payload.getClaim("id").asString()?.let { UUID.fromString(it) }

    fun extractUserId(token: String): UUID? = runCatching {
        val decoded = verifier.verify(token)
        decoded.getClaim("id").asString()?.let { UUID.fromString(it) }
    }.getOrNull()

    companion object {
        private const val TOKEN_VALIDITY = 1000 * 60 * 60 * 24L
    }
}
