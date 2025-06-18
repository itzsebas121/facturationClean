package com.example.shop_car.domain.usecase

import com.example.shop_car.domain.model.Category
import com.example.shop_car.domain.repository.CategoryRepository
import javax.inject.Inject

data class CategoryUseCases @Inject constructor(
    val getCategories: GetCategories,
    val getCategoryById: GetCategoryById,
    val createCategory: CreateCategory,
    val updateCategory: UpdateCategory,
    val deleteCategory: DeleteCategory,
) {
    class GetCategories @Inject constructor(private val repo: CategoryRepository) {
        suspend operator fun invoke(): List<Category> = repo.getCategories()
    }
    class GetCategoryById @Inject constructor(private val repo: CategoryRepository) {
        suspend operator fun invoke(id: Int): Category? = repo.getCategoryById(id)
    }
    class CreateCategory @Inject constructor(private val repo: CategoryRepository) {
        suspend operator fun invoke(category: Category): Boolean = repo.createCategory(category)
    }
    class UpdateCategory @Inject constructor(private val repo: CategoryRepository) {
        suspend operator fun invoke(category: Category): Boolean = repo.updateCategory(category)
    }
    class DeleteCategory @Inject constructor(private val repo: CategoryRepository) {
        suspend operator fun invoke(id: Int): Boolean = repo.deleteCategory(id)
    }
}