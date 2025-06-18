package com.example.shop_car.domain.usecase

import com.example.shop_car.domain.model.Order
import com.example.shop_car.domain.repository.OrderRepository
import javax.inject.Inject

data class OrderUseCases @Inject constructor(
    val getOrders: GetOrders,
    val getOrderById: GetOrderById,
    val createOrder: CreateOrder,
    val updateOrder: UpdateOrder,
    val deleteOrder: DeleteOrder,
) {
    class GetOrders @Inject constructor(private val repo: OrderRepository) {
        suspend operator fun invoke(): List<Order> = repo.getOrders()
    }
    class GetOrderById @Inject constructor(private val repo: OrderRepository) {
        suspend operator fun invoke(id: Int): Order? = repo.getOrderById(id)
    }
    class CreateOrder @Inject constructor(private val repo: OrderRepository) {
        suspend operator fun invoke(order: Order): Boolean = repo.createOrder(order)
    }
    class UpdateOrder @Inject constructor(private val repo: OrderRepository) {
        suspend operator fun invoke(order: Order): Boolean = repo.updateOrder(order)
    }
    class DeleteOrder @Inject constructor(private val repo: OrderRepository) {
        suspend operator fun invoke(id: Int): Boolean = repo.deleteOrder(id)
    }
}