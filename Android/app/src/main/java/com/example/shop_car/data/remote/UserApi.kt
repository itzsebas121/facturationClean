package com.example.shop_car.data.remote

import com.example.shop_car.data.remote.dto.UserDto
import retrofit2.http.*

interface UserApi {
    @GET("api/users")
    suspend fun getUsers(): List<UserDto>

    @GET("api/users/{id}")
    suspend fun getUserById(@Path("id") id: Int): UserDto?

    @POST("api/users")
    suspend fun createUser(@Body user: UserDto): Boolean

    @PUT("api/users/{id}")
    suspend fun updateUser(@Path("id") id: Int, @Body user: UserDto): Boolean

    @DELETE("api/users/{id}")
    suspend fun deleteUser(@Path("id") id: Int): Boolean
}