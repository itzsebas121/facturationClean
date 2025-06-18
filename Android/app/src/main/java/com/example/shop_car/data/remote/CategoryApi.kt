package com.example.shop_car.data.remote

import com.example.shop_car.data.remote.dto.CategoryDto
import retrofit2.http.*

interface CategoryApi {
    @GET("api/categories")
    suspend fun getCategories(): List<CategoryDto>

    @GET("api/categories/{id}")
    suspend fun getCategoryById(@Path("id") id: Int): CategoryDto?

    @POST("api/categories")
    suspend fun createCategory(@Body category: CategoryDto): Boolean

    @PUT("api/categories/{id}")
    suspend fun updateCategory(@Path("id") id: Int, @Body category: CategoryDto): Boolean

    @DELETE("api/categories/{id}")
    suspend fun deleteCategory(@Path("id") id: Int): Boolean
}