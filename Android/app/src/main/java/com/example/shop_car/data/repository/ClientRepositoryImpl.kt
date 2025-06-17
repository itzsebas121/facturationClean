package com.example.shop_car.data.repository
import com.example.shop_car.data.remote.dto.toDto
import com.example.shop_car.data.remote.dto.toDomain
import com.example.shop_car.domain.model.Client
import com.example.shop_car.domain.repository.ClientRepository

class ClientRepositoryImpl (private val api: ClientApi): ClientRepository {
    override suspend fun getClients(): List<Client> =
        api.getClients().map { it.toDomain() }

    override suspend fun getClientById(id: Int): Client? =
        api.getClientById(id)?.toDomain()

    override suspend fun createClient(client: Client): Boolean =
        api.createClient(client.toDto())

    override suspend fun updateClient(client: Client): Boolean =
        api.updateClient(client.toDto())

    override suspend fun deleteClient(id: Int): Boolean =
        api.deleteClient(id)
}