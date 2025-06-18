package com.example.shop_car.data.remote

import com.example.shop_car.data.remote.dto.OrderDetailDto
import retrofit2.http.*

interface OrderDetailApi {
    @GET("api/orderdetails")
    suspend fun getOrderDetails(): List<OrderDetailDto>

    @GET("api/orderdetails/{id}")
    suspend fun getOrderDetailById(@Path("id") id: Int): OrderDetailDto?

    @POST("api/orderdetails")
    suspend fun createOrderDetail(@Body orderDetail: OrderDetailDto): Boolean

    @PUT("api/orderdetails/{id}")
    suspend fun updateOrderDetail(@Path("id") id: Int, @Body orderDetail: OrderDetailDto): Boolean

    @DELETE("api/orderdetails/{id}")
    suspend fun deleteOrderDetail(@Path("id") id: Int): Boolean
}