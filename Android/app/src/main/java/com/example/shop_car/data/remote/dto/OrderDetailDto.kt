package com.example.shop_car.data.remote.dto

data class OrderDetailDto(
    val orderDetailId: Int,
    val orderId: Int,
    val productId: Int,
    val quantity: Int,
    val unitPrice: Double
)