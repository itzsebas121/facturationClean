package com.example.shop_car.data.remote

import com.example.shop_car.data.remote.dto.AdminDto
import retrofit2.http.*

interface AdminApi {
    @GET("api/admins")
    suspend fun getAdmins(): List<AdminDto>

    @GET("api/admins/{id}")
    suspend fun getAdminById(@Path("id") id: Int): AdminDto?

    @POST("api/admins")
    suspend fun createAdmin(@Body admin: AdminDto): Boolean

    @PUT("api/admins/{id}")
    suspend fun updateAdmin(@Path("id") id: Int, @Body admin: AdminDto): Boolean

    @DELETE("api/admins/{id}")
    suspend fun deleteAdmin(@Path("id") id: Int): Boolean
}