package com.example.shop_car.domain.model

data class Client(
    val clientId: Int,
    val userId: Int,
    val firstName: String,
    val lastName: String,
    val address: String,
    val phone: String
)