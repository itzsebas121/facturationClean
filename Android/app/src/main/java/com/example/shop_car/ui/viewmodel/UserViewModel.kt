package com.example.shop_car.presentation.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.shop_car.domain.model.User
import com.example.shop_car.domain.usecase.UserUseCases
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class UserViewModel @Inject constructor(
    private val userUseCases: UserUseCases
) : ViewModel() {

    private val _users = MutableStateFlow<List<User>>(emptyList())
    val users: StateFlow<List<User>> = _users

    private val _selectedUser = MutableStateFlow<User?>(null)
    val selectedUser: StateFlow<User?> = _selectedUser

    fun loadUsers() {
        viewModelScope.launch {
            _users.value = userUseCases.getUsers()
        }
    }

    fun getUserById(id: Int) {
        viewModelScope.launch {
            _selectedUser.value = userUseCases.getUserById(id)
        }
    }

    fun createUser(user: User, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = userUseCases.createUser(user)
            if (result) loadUsers()
            onResult(result)
        }
    }

    fun updateUser(user: User, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = userUseCases.updateUser(user)
            if (result) loadUsers()
            onResult(result)
        }
    }

    fun deleteUser(id: Int, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = userUseCases.deleteUser(id)
            if (result) loadUsers()
            onResult(result)
        }
    }
}