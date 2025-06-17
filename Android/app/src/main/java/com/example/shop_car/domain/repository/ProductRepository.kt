package com.example.shop_car.domain.repository;

import com.example.shop_car.domain.model.Product;

interface ProductRepository{
    suspend fun getProducts(): List<Product>
    suspend fun getProductById(id: Int): Product?
    suspend fun createProduct(product: Product): Boolean
}