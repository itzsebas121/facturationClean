package com.example.shop_car.presentation.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.shop_car.domain.model.Category
import com.example.shop_car.domain.usecase.CategoryUseCases
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class CategoryViewModel @Inject constructor(
    private val categoryUseCases: CategoryUseCases
) : ViewModel() {

    private val _categories = MutableStateFlow<List<Category>>(emptyList())
    val categories: StateFlow<List<Category>> = _categories

    private val _selectedCategory = MutableStateFlow<Category?>(null)
    val selectedCategory: StateFlow<Category?> = _selectedCategory

    fun loadCategories() {
        viewModelScope.launch {
            _categories.value = categoryUseCases.getCategories()
        }
    }

    fun getCategoryById(id: Int) {
        viewModelScope.launch {
            _selectedCategory.value = categoryUseCases.getCategoryById(id)
        }
    }

    fun createCategory(category: Category, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = categoryUseCases.createCategory(category)
            if (result) loadCategories()
            onResult(result)
        }
    }

    fun updateCategory(category: Category, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = categoryUseCases.updateCategory(category)
            if (result) loadCategories()
            onResult(result)
        }
    }

    fun deleteCategory(id: Int, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = categoryUseCases.deleteCategory(id)
            if (result) loadCategories()
            onResult(result)
        }
    }
}