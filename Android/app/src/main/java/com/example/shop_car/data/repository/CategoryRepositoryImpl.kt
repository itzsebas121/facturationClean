package com.example.shop_car.data.repository

import com.example.shop_car.domain.repository.CategoryRepository
import com.example.shop_car.domain.model.Category
import com.example.shop_car.data.remote.dto.toDto
import com.example.shop_car.data.remote.dto.toDomain

class CategoryRepositoryImpl(
    private val api: CategoryApi
) : CategoryRepository {

    override suspend fun getCategories(): List<Category> =
        api.getCategories().map { it.toDomain() }

    override suspend fun getCategoryById(id: Int): Category? =
        api.getCategoryById(id)?.toDomain()

    override suspend fun createCategory(category: Category): Boolean =
        api.createCategory(category.toDto())

    override suspend fun updateCategory(category: Category): Boolean =
        api.updateCategory(category.toDto())

    override suspend fun deleteCategory(id: Int): Boolean =
        api.deleteCategory(id)
}