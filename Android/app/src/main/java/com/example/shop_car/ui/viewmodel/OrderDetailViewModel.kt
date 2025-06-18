package com.example.shop_car.presentation.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.shop_car.domain.model.OrderDetail
import com.example.shop_car.domain.usecase.OrderDetailUseCases
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class OrderDetailViewModel @Inject constructor(
    private val orderDetailUseCases: OrderDetailUseCases
) : ViewModel() {

    private val _orderDetails = MutableStateFlow<List<OrderDetail>>(emptyList())
    val orderDetails: StateFlow<List<OrderDetail>> = _orderDetails

    private val _selectedOrderDetail = MutableStateFlow<OrderDetail?>(null)
    val selectedOrderDetail: StateFlow<OrderDetail?> = _selectedOrderDetail

    fun loadOrderDetails() {
        viewModelScope.launch {
            _orderDetails.value = orderDetailUseCases.getOrderDetails()
        }
    }

    fun getOrderDetailById(id: Int) {
        viewModelScope.launch {
            _selectedOrderDetail.value = orderDetailUseCases.getOrderDetailById(id)
        }
    }

    fun createOrderDetail(orderDetail: OrderDetail, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = orderDetailUseCases.createOrderDetail(orderDetail)
            if (result) loadOrderDetails()
            onResult(result)
        }
    }

    fun updateOrderDetail(orderDetail: OrderDetail, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = orderDetailUseCases.updateOrderDetail(orderDetail)
            if (result) loadOrderDetails()
            onResult(result)
        }
    }

    fun deleteOrderDetail(id: Int, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = orderDetailUseCases.deleteOrderDetail(id)
            if (result) loadOrderDetails()
            onResult(result)
        }
    }
}