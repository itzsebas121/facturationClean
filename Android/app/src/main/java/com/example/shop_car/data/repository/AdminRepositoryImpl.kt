package com.example.shop_car.data.repository

import com.example.shop_car.data.remote.dto.toDto
import com.example.shop_car.data.remote.dto.toDomain
import com.example.shop_car.domain.model.Admin
import com.example.shop_car.domain.repository.AdminRepository

class AdminRepositoryImpl(
    private val api: AdminApi
) : AdminRepository {

    override suspend fun getAdmins(): List<Admin> =
        api.getAdmins().map { it.toDomain() }

    override suspend fun getAdminById(id: Int): Admin? =
        api.getAdminById(id)?.toDomain()

    override suspend fun createAdmin(admin: Admin): Boolean =
        api.createAdmin(admin.toDto())

    override suspend fun updateAdmin(admin: Admin): Boolean =
        api.updateAdmin(admin.toDto())

    override suspend fun deleteAdmin(id: Int): Boolean =
        api.deleteAdmin(id)
}