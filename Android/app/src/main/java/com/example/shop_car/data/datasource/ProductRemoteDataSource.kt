package com.example.shop_car.data.datasource

import com.example.shop_car.data.remote.dto.ProductDto

class ProductRemoteDataSource (private val api: ProductApi) {
    suspend fun fetchProducts(): List<ProductDto> = api.getProducts()
    suspend fun fetchProduct(id: Int): ProductDto = api.getProduct(id)
}