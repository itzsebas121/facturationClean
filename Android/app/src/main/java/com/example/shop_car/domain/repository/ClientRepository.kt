package com.example.shop_car.domain.repository

import com.example.shop_car.domain.model.Client

interface ClientRepository {
    suspend fun getClients(): List<Client>
    suspend fun getClientById(id: Int): Client?
    suspend fun createClient(client: Client): Boolean
    suspend fun updateClient(client: Client): Boolean
    suspend fun deleteClient(id: Int): Boolean
}