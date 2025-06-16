package com.example.shop_car.domain.repository

import com.example.shop_car.domain.model.Order

interface OrderRepository {
    suspend fun getOrders(): List<Order>
    suspend fun getOrderById(id: Int): Order?
    suspend fun createOrder(order: Order): Boolean
    suspend fun updateOrder(order: Order): Boolean
    suspend fun deleteOrder(id: Int): Boolean
}