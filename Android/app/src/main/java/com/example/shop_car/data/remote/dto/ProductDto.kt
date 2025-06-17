package com.example.shop_car.data.remote.dto

data class ProductDto(
    val productId: Int,
    val categoryId: Int,
    val name: String,
    val description: String?,
    val price: Double,
    val stock: Int,
    val imageUrl: String?
)