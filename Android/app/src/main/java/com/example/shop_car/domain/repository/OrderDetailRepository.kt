package com.example.shop_car.domain.repository

import com.example.shop_car.domain.model.OrderDetail

interface OrderDetailRepository {
    suspend fun getOrderDetails(): List<OrderDetail>
    suspend fun getOrderDetailById(id: Int): OrderDetail?
    suspend fun createOrderDetail(orderDetail: OrderDetail): Boolean
    suspend fun updateOrderDetail(orderDetail: OrderDetail): Boolean
    suspend fun deleteOrderDetail(id: Int): Boolean
}