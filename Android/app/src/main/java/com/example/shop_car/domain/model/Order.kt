package com.example.shop_car.domain.model

data class Order(
    val orderId: Int,
    val clientId: Int,
    val orderDate: String,
    val total: Double,
    val subTotal: Double,
    val tax: Double
)