package com.example.shop_car.domain.usecase

import com.example.shop_car.domain.model.User
import com.example.shop_car.domain.repository.UserRepository
import javax.inject.Inject

data class UserUseCases @Inject constructor(
    val getUsers: GetUsers,
    val getUserById: GetUserById,
    val createUser: CreateUser,
    val updateUser: UpdateUser,
    val deleteUser: DeleteUser,
) {
    class GetUsers @Inject constructor(private val repo: UserRepository) {
        suspend operator fun invoke(): List<User> = repo.getUsers()
    }
    class GetUserById @Inject constructor(private val repo: UserRepository) {
        suspend operator fun invoke(id: Int): User? = repo.getUserById(id)
    }
    class CreateUser @Inject constructor(private val repo: UserRepository) {
        suspend operator fun invoke(user: User): Boolean = repo.createUser(user)
    }
    class UpdateUser @Inject constructor(private val repo: UserRepository) {
        suspend operator fun invoke(user: User): Boolean = repo.updateUser(user)
    }
    class DeleteUser @Inject constructor(private val repo: UserRepository) {
        suspend operator fun invoke(id: Int): Boolean = repo.deleteUser(id)
    }
}