package com.example.shop_car.domain.repository

import com.example.shop_car.domain.model.Category

interface CategoryRepository {
    suspend fun getCategories(): List<Category>
    suspend fun getCategoryById(id: Int): Category?
    suspend fun createCategory(category: Category): Boolean
    suspend fun updateCategory(category: Category): Boolean
    suspend fun deleteCategory(id: Int): Boolean
}