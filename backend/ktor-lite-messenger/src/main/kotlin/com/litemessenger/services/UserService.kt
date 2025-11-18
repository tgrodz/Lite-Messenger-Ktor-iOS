package com.litemessenger.services

import com.litemessenger.domain.UserPreview
import com.litemessenger.domain.UserProfile
import com.litemessenger.entities.UsersTable
import org.jetbrains.exposed.sql.ResultRow
import org.jetbrains.exposed.sql.insertAndGetId
import org.jetbrains.exposed.sql.or
import org.jetbrains.exposed.sql.select
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.like
import java.security.MessageDigest
import java.util.Locale
import java.util.UUID

class UserService(private val avatarService: AvatarService) {

    suspend fun createUser(name: String, email: String, password: String): UserProfile = DatabaseFactory.dbQuery {
        val normalizedEmail = email.trim().lowercase(Locale.getDefault())
        val existing = UsersTable.select { UsersTable.email eq normalizedEmail }.count()
        require(existing == 0L) { "Email already registered" }
        val abbr = abbreviationFrom(name)
        val newId = UsersTable.insertAndGetId {
            it[UsersTable.name] = name.trim()
            it[UsersTable.email] = normalizedEmail
            it[UsersTable.passwordHash] = hashPassword(password)
            it[UsersTable.abbreviation] = abbr
            it[UsersTable.createdAt] = System.currentTimeMillis()
        }.value
        getUserRecordInternal(newId)?.toProfile() ?: error("User not created")
    }

    suspend fun authenticate(email: String, password: String): UserProfile? = DatabaseFactory.dbQuery {
        val normalizedEmail = email.trim().lowercase(Locale.getDefault())
        val row = UsersTable.select { UsersTable.email eq normalizedEmail }.singleOrNull() ?: return@dbQuery null
        val record = row.toRecord()
        if (record.passwordHash == hashPassword(password)) record.toProfile() else null
    }

    suspend fun findUserProfile(id: UUID): UserProfile? = DatabaseFactory.dbQuery { getUserRecordInternal(id)?.toProfile() }

    suspend fun getUserPreview(id: UUID): UserPreview? = DatabaseFactory.dbQuery { getUserRecordInternal(id)?.toPreview() }

    suspend fun updateAvatar(userId: UUID, avatarFile: String): UserProfile? = DatabaseFactory.dbQuery {
        UsersTable.update({ UsersTable.id eq userId }) {
            it[UsersTable.avatarFile] = avatarFile
        }
        getUserRecordInternal(userId)?.toProfile()
    }

    suspend fun countUsers(): Long = DatabaseFactory.dbQuery { UsersTable.selectAll().count() }

    suspend fun searchUsers(currentUser: UUID, term: String): List<UserPreview> = DatabaseFactory.dbQuery {
        if (term.isBlank()) return@dbQuery emptyList()
        val query = "%${term.trim()}%"
        UsersTable.select { (UsersTable.name like query) or (UsersTable.email like query) }
            .map { it.toRecord() }
            .filterNot { it.id == currentUser }
            .map { it.toPreview() }
    }

    fun resolveAvatarLocation(file: String?): String? = avatarService.resolvePublicUrl(file)

    private fun abbreviationFrom(name: String): String {
        val pieces = name.trim().split(Regex("\\s+")).filter { it.isNotEmpty() }
        val first = pieces.getOrNull(0)?.firstOrNull()?.uppercaseChar()?.toString() ?: "X"
        val second = pieces.getOrNull(1)?.firstOrNull()?.uppercaseChar()?.toString()
            ?: pieces.getOrNull(0)?.drop(1)?.firstOrNull()?.uppercaseChar()?.toString()
            ?: "Y"
        return (first + second).take(2)
    }

    private fun hashPassword(password: String): String {
        val digest = MessageDigest.getInstance("SHA-256").digest(password.toByteArray())
        return digest.joinToString(separator = "") { byte -> "%02x".format(byte) }
    }

    private fun ResultRow.toRecord(): UserRecord = UserRecord(
        id = this[UsersTable.id].value,
        name = this[UsersTable.name],
        email = this[UsersTable.email],
        passwordHash = this[UsersTable.passwordHash],
        avatarFile = this[UsersTable.avatarFile],
        abbreviation = this[UsersTable.abbreviation]
    )

    private fun UserRecord.toProfile(): UserProfile = UserProfile(
        id = id.toString(),
        name = name,
        email = email,
        avatarUrl = avatarService.resolvePublicUrl(avatarFile),
        abbreviation = abbreviation
    )

    private fun UserRecord.toPreview(): UserPreview = UserPreview(
        id = id.toString(),
        name = name,
        abbreviation = abbreviation,
        avatarUrl = avatarService.resolvePublicUrl(avatarFile),
        email = email
    )

    private fun getUserRecordInternal(id: UUID): UserRecord? =
        UsersTable.select { UsersTable.id eq id }.singleOrNull()?.toRecord()

    data class UserRecord(
        val id: UUID,
        val name: String,
        val email: String,
        val passwordHash: String,
        val avatarFile: String?,
        val abbreviation: String
    )
}
