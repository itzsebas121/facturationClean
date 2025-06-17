package com.example.shop_car.data.remote.dto

data class AdminDto (
    val adminId: Int,
    val userId: Int,
    val firstName: String,
    val lastName: String,
    val address: String?,
    val phone: String?
)