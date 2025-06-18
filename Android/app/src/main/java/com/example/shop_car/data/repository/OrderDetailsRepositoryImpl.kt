package com.example.shop_car.data.repository

import com.example.shop_car.data.remote.OrderDetailApi
import com.example.shop_car.data.remote.dto.toDomain
import com.example.shop_car.data.remote.dto.toDto
import com.example.shop_car.domain.model.OrderDetail
import com.example.shop_car.domain.repository.OrderDetailRepository

class OrderDetailRepositoryImpl(
    private val api: OrderDetailApi
) : OrderDetailRepository {

    override suspend fun getOrderDetails(): List<OrderDetail> =
        api.getOrderDetails().map { it.toDomain() }

    override suspend fun getOrderDetailById(id: Int): OrderDetail? =
        api.getOrderDetailById(id)?.toDomain()

    override suspend fun createOrderDetail(orderDetail: OrderDetail): Boolean =
        api.createOrderDetail(orderDetail.toDto())

    override suspend fun updateOrderDetail(orderDetail: OrderDetail): Boolean =
        api.updateOrderDetail(orderDetail.orderDetailId,orderDetail.toDto())

    override suspend fun deleteOrderDetail(id: Int): Boolean =
        api.deleteOrderDetail(id)
}