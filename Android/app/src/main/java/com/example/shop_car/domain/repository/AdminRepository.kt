package com.example.shop_car.domain.repository

import com.example.shop_car.domain.model.Admin

interface AdminRepository {
    suspend fun getAdmins(): List<Admin>
    suspend fun getAdminById(id: Int): Admin?
    suspend fun createAdmin(admin: Admin): Boolean
    suspend fun updateAdmin(admin: Admin): Boolean
    suspend fun deleteAdmin(id: Int): Boolean
}