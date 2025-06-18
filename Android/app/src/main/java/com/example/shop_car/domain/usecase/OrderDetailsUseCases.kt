package com.example.shop_car.domain.usecase

import com.example.shop_car.domain.model.OrderDetail
import com.example.shop_car.domain.repository.OrderDetailRepository
import javax.inject.Inject

data class OrderDetailUseCases @Inject constructor(
    val getOrderDetails: GetOrderDetails,
    val getOrderDetailById: GetOrderDetailById,
    val createOrderDetail: CreateOrderDetail,
    val updateOrderDetail: UpdateOrderDetail,
    val deleteOrderDetail: DeleteOrderDetail,
) {
    class GetOrderDetails @Inject constructor(private val repo: OrderDetailRepository) {
        suspend operator fun invoke(): List<OrderDetail> = repo.getOrderDetails()
    }
    class GetOrderDetailById @Inject constructor(private val repo: OrderDetailRepository) {
        suspend operator fun invoke(id: Int): OrderDetail? = repo.getOrderDetailById(id)
    }
    class CreateOrderDetail @Inject constructor(private val repo: OrderDetailRepository) {
        suspend operator fun invoke(orderDetail: OrderDetail): Boolean = repo.createOrderDetail(orderDetail)
    }
    class UpdateOrderDetail @Inject constructor(private val repo: OrderDetailRepository) {
        suspend operator fun invoke(orderDetail: OrderDetail): Boolean = repo.updateOrderDetail(orderDetail)
    }
    class DeleteOrderDetail @Inject constructor(private val repo: OrderDetailRepository) {
        suspend operator fun invoke(id: Int): Boolean = repo.deleteOrderDetail(id)
    }
}