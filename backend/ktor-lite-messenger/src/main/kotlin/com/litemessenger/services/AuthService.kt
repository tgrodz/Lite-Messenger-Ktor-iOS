package com.litemessenger.services

import com.litemessenger.domain.AuthResponse
import com.litemessenger.domain.LoginRequest
import com.litemessenger.domain.RegisterRequest
import com.litemessenger.domain.UserProfile
import java.util.UUID

class AuthService(
    private val userService: UserService,
    private val tokenService: TokenService
) {
    suspend fun register(request: RegisterRequest): AuthResponse {
        val name = request.name.trim()
        require(name.isNotBlank()) { "Name is required" }
        val user = userService.createUser(name, request.email, request.password)
        val token = tokenService.generate(UUID.fromString(user.id), user.email)
        return AuthResponse(token, user)
    }

    suspend fun login(request: LoginRequest): AuthResponse {
        val user = userService.authenticate(request.email, request.password)
            ?: throw IllegalArgumentException("Invalid credentials")
        val token = tokenService.generate(UUID.fromString(user.id), user.email)
        return AuthResponse(token, user)
    }

    suspend fun profile(userId: UUID): UserProfile? = userService.findUserProfile(userId)
}
