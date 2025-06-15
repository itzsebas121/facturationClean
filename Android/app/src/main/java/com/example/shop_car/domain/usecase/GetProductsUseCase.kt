package com.example.shop_car.domain.usecase

import com.example.shop_car.domain.model.Product
import com.example.shop_car.domain.repository.ProductRepository

class GetProductsUseCase (private val repository: ProductRepository){
    suspend operator fun invoke(): List<Product> = repository.getProducts()
}