package com.example.shop_car.presentation.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.shop_car.domain.model.Order
import com.example.shop_car.domain.usecase.OrderUseCases
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class OrderViewModel @Inject constructor(
    private val orderUseCases: OrderUseCases
) : ViewModel() {

    private val _orders = MutableStateFlow<List<Order>>(emptyList())
    val orders: StateFlow<List<Order>> = _orders

    private val _selectedOrder = MutableStateFlow<Order?>(null)
    val selectedOrder: StateFlow<Order?> = _selectedOrder

    fun loadOrders() {
        viewModelScope.launch {
            _orders.value = orderUseCases.getOrders()
        }
    }

    fun getOrderById(id: Int) {
        viewModelScope.launch {
            _selectedOrder.value = orderUseCases.getOrderById(id)
        }
    }

    fun createOrder(order: Order, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = orderUseCases.createOrder(order)
            if (result) loadOrders()
            onResult(result)
        }
    }

    fun updateOrder(order: Order, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = orderUseCases.updateOrder(order)
            if (result) loadOrders()
            onResult(result)
        }
    }

    fun deleteOrder(id: Int, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = orderUseCases.deleteOrder(id)
            if (result) loadOrders()
            onResult(result)
        }
    }
}