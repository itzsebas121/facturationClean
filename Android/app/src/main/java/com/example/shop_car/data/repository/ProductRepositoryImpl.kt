package com.example.shop_car.data.repository

import com.example.shop_car.data.remote.ProductApi
import com.example.shop_car.domain.model.Product
import com.example.shop_car.domain.repository.ProductRepository
import com.example.shop_car.data.remote.dto.toDomain
import com.example.shop_car.data.remote.dto.toDto

class ProductRepositoryImpl (
    private val api:ProductApi
): ProductRepository {
    override suspend fun getProducts(): List<Product> {
        val productsDtos=api.getProducts()
        return productsDtos.map { it.toDomain() }
    }
    override suspend fun getProductById(id: Int): Product? {
        val productDto=api.getProductById(id)
        return productDto?.toDomain()
    }
    override suspend fun createProduct(product: Product): Boolean {
        val productDto=product.toDto()
        return api.createProduct(productDto)
    }
}