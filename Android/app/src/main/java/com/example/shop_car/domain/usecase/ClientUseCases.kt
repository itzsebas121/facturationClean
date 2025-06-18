package com.example.shop_car.domain.usecase

import com.example.shop_car.domain.model.Client
import com.example.shop_car.domain.repository.ClientRepository
import javax.inject.Inject

data class ClientUseCases @Inject constructor(
    val getClients: GetClients,
    val getClientById: GetClientById,
    val createClient: CreateClient,
    val updateClient: UpdateClient,
    val deleteClient: DeleteClient,
) {
    class GetClients @Inject constructor(private val repo: ClientRepository) {
        suspend operator fun invoke(): List<Client> = repo.getClients()
    }
    class GetClientById @Inject constructor(private val repo: ClientRepository) {
        suspend operator fun invoke(id: Int): Client? = repo.getClientById(id)
    }
    class CreateClient @Inject constructor(private val repo: ClientRepository) {
        suspend operator fun invoke(client: Client): Boolean = repo.createClient(client)
    }
    class UpdateClient @Inject constructor(private val repo: ClientRepository) {
        suspend operator fun invoke(client: Client): Boolean = repo.updateClient(client)
    }
    class DeleteClient @Inject constructor(private val repo: ClientRepository) {
        suspend operator fun invoke(id: Int): Boolean = repo.deleteClient(id)
    }
}