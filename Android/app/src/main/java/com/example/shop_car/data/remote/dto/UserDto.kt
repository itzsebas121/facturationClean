package com.example.shop_car.data.remote.dto

data class UserDto(
    val userId: Int,
    val cedula: String,
    val email: String,
    val passwordHash: String,
    val roleId: Int,
    val registrationDate: String,
    val isBlocked: Boolean,
    val failedLoginAttempts: Int
)