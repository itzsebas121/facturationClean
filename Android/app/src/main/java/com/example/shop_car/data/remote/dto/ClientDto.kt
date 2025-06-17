package com.example.shop_car.data.remote.dto

data class ClientDto(
    val clientId: Int,
    val userId: Int,
    val firstName: String,
    val lastName: String,
    val address: String,
    val phone: String
)