package com.example.shop_car.data.repository

import com.example.shop_car.data.remote.OrderApi
import com.example.shop_car.data.remote.dto.toDomain
import com.example.shop_car.data.remote.dto.toDto
import com.example.shop_car.domain.model.Order
import com.example.shop_car.domain.repository.OrderRepository

class OrderRepositoryImpl(
    private val api: OrderApi
) : OrderRepository {

    override suspend fun getOrders(): List<Order> =
        api.getOrders().map { it.toDomain() }

    override suspend fun getOrderById(id: Int): Order? =
        api.getOrderById(id)?.toDomain()

    override suspend fun createOrder(order: Order): Boolean =
        api.createOrder(order.toDto())

    override suspend fun updateOrder(order: Order): Boolean =
        api.updateOrder(order.orderId,order.toDto())

    override suspend fun deleteOrder(id: Int): Boolean =
        api.deleteOrder(id)
}