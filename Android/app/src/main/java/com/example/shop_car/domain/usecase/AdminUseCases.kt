package com.example.shop_car.domain.usecase

import com.example.shop_car.domain.model.Admin
import com.example.shop_car.domain.repository.AdminRepository
import javax.inject.Inject

data class AdminUseCases @Inject constructor(
    val getAdmins: GetAdmins,
    val getAdminById: GetAdminById,
    val createAdmin: CreateAdmin,
    val updateAdmin: UpdateAdmin,
    val deleteAdmin: DeleteAdmin,
) {
    class GetAdmins @Inject constructor(private val repo: AdminRepository) {
        suspend operator fun invoke(): List<Admin> = repo.getAdmins()
    }
    class GetAdminById @Inject constructor(private val repo: AdminRepository) {
        suspend operator fun invoke(id: Int): Admin? = repo.getAdminById(id)
    }
    class CreateAdmin @Inject constructor(private val repo: AdminRepository) {
        suspend operator fun invoke(admin: Admin): Boolean = repo.createAdmin(admin)
    }
    class UpdateAdmin @Inject constructor(private val repo: AdminRepository) {
        suspend operator fun invoke(admin: Admin): Boolean = repo.updateAdmin(admin)
    }
    class DeleteAdmin @Inject constructor(private val repo: AdminRepository) {
        suspend operator fun invoke(id: Int): Boolean = repo.deleteAdmin(id)
    }
}