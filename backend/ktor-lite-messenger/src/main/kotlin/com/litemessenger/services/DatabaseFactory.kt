package com.litemessenger.services

import com.litemessenger.entities.ChatsTable
import com.litemessenger.entities.MessagesTable
import com.litemessenger.entities.UsersTable
import kotlinx.coroutines.Dispatchers
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.transactions.TransactionManager
import org.jetbrains.exposed.sql.transactions.experimental.newSuspendedTransaction
import org.jetbrains.exposed.sql.transactions.transaction
import java.sql.Connection

object DatabaseFactory {
    fun init() {
        Database.connect(
            url = "jdbc:h2:mem:lite-messenger;DB_CLOSE_DELAY=-1;",
            driver = "org.h2.Driver"
        )
        TransactionManager.manager.defaultIsolationLevel = Connection.TRANSACTION_SERIALIZABLE
        transaction {
            SchemaUtils.create(UsersTable, ChatsTable, MessagesTable)
        }
    }

    suspend fun <T> dbQuery(block: suspend () -> T): T = newSuspendedTransaction(Dispatchers.IO) { block() }
}
