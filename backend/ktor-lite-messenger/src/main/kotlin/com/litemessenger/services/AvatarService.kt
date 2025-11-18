package com.litemessenger.services

import java.io.File
import java.util.UUID

class AvatarService(storageDir: File) {
    private val directory: File = storageDir.apply { mkdirs() }

    fun saveAvatar(bytes: ByteArray, originalName: String?): String {
        val extension = originalName?.substringAfterLast('.', "png")?.lowercase()?.takeIf { it.matches(Regex("[a-z0-9]{1,5}")) }
            ?: "png"
        val fileName = "${UUID.randomUUID()}.$extension"
        File(directory, fileName).writeBytes(bytes)
        return fileName
    }

    fun resolvePublicUrl(fileName: String?): String? = fileName?.let { "/avatars/$it" }

    fun storageRoot(): File = directory
}
