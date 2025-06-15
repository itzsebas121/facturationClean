package com.example.shop_car.data.remote.dto

data class OrderDto(
    val orderId: Int,
    val clientId: Int,
    val orderDate: String,
    val total: Double,
    val subTotal: Double,
    val tax: Double,
)