package com.example.shop_car.presentation.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.shop_car.domain.model.Admin
import com.example.shop_car.domain.usecase.AdminUseCases
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AdminViewModel @Inject constructor(
    private val adminUseCases: AdminUseCases
) : ViewModel() {

    private val _admins = MutableStateFlow<List<Admin>>(emptyList())
    val admins: StateFlow<List<Admin>> = _admins

    private val _selectedAdmin = MutableStateFlow<Admin?>(null)
    val selectedAdmin: StateFlow<Admin?> = _selectedAdmin

    fun loadAdmins() {
        viewModelScope.launch {
            _admins.value = adminUseCases.getAdmins()
        }
    }

    fun getAdminById(id: Int) {
        viewModelScope.launch {
            _selectedAdmin.value = adminUseCases.getAdminById(id)
        }
    }

    fun createAdmin(admin: Admin, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = adminUseCases.createAdmin(admin)
            if (result) loadAdmins()
            onResult(result)
        }
    }

    fun updateAdmin(admin: Admin, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = adminUseCases.updateAdmin(admin)
            if (result) loadAdmins()
            onResult(result)
        }
    }

    fun deleteAdmin(id: Int, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = adminUseCases.deleteAdmin(id)
            if (result) loadAdmins()
            onResult(result)
        }
    }
}