package com.example.shop_car.data.remote

import com.example.shop_car.data.remote.dto.ProductDto
import retrofit2.http.*

interface ProductApi {
    @GET("api/products")
    suspend fun getProducts(): List<ProductDto>
    @GET("api/products/{id}")
    suspend fun getProductById(@Path("id") id: Int): ProductDto?
    @POST("api/products")
    suspend fun createProduct(@Body product: ProductDto): Boolean
}