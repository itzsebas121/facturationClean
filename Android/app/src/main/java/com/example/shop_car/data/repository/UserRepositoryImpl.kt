package com.example.shop_car.data.repository

import com.example.shop_car.data.remote.dto.toDto
import com.example.shop_car.domain.model.User
import com.example.shop_car.domain.repository.UserRepository

class UserRepositoryImpl (private val api:UserApi): UserRepository {
    override suspend fun getUsers(): List<User> =
        api.getUsers().map { it.toDomain() }

    override suspend fun getUserById(id: Int): User? =
        api.getUserById(id)?.toDomain()

    override suspend fun createUser(user: User): Boolean =
        api.createUser(user.toDto())

    override suspend fun updateUser(user: User): Boolean =
        api.updateUser(user.toDto())

    override suspend fun deleteUser(id: Int): Boolean =
        api.deleteUser(id)
}