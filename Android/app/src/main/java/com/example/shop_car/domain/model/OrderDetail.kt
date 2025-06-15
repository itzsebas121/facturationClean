package com.example.shop_car.domain.model

data class OrderDetail(
    val orderDetailId: Int,
    val orderId: Int,
    val productId: Int,
    val quantity: Int,
    val unitPrice: Double
)