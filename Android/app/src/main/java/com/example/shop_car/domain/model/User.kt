package com.example.shop_car.domain.model

data class User(
    val userId: Int,
    val cedula: String,
    val email: String,
    val passwordHash: String,
    val roleId: Int,
    val registrationDate: String,
    val isBlocked: Boolean,
    val failedLoginAttempts: Int
)