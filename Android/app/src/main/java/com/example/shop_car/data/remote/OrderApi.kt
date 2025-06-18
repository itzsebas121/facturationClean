package com.example.shop_car.data.remote

import com.example.shop_car.data.remote.dto.OrderDto
import retrofit2.http.*

interface OrderApi {
    @GET("api/orders")
    suspend fun getOrders(): List<OrderDto>

    @GET("api/orders/{id}")
    suspend fun getOrderById(@Path("id") id: Int): OrderDto?

    @POST("api/orders")
    suspend fun createOrder(@Body order: OrderDto): Boolean

    @PUT("api/orders/{id}")
    suspend fun updateOrder(@Path("id") id: Int, @Body order: OrderDto): Boolean

    @DELETE("api/orders/{id}")
    suspend fun deleteOrder(@Path("id") id: Int): Boolean
}