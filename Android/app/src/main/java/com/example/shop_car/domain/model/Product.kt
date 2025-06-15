package com.example.shop_car.domain.model

data class Product(
    val productId: Int,
    val categoryId: Int,
    val name: String,
    val description: String?,
    val price: Double,
    val stock: Int,
    val imageUrl: String?
)