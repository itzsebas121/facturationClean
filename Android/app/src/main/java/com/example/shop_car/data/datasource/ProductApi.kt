package com.example.shop_car.data.datasource

import com.example.shop_car.data.remote.dto.ProductDto
import retrofit2.http.GET
import retrofit2.http.Path

interface ProductApi {
    @GET("products")
    suspend fun getProducts(): List<ProductDto>

    @GET("products/{id}")
    suspend fun getProduct(@Path("id") id: Int): ProductDto
}