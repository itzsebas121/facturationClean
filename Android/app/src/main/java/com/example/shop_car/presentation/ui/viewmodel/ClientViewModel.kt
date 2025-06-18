package com.example.shop_car.presentation.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.shop_car.domain.model.Client
import com.example.shop_car.domain.usecase.ClientUseCases
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ClientViewModel @Inject constructor(
    private val clientUseCases: ClientUseCases
) : ViewModel() {

    private val _clients = MutableStateFlow<List<Client>>(emptyList())
    val clients: StateFlow<List<Client>> = _clients

    private val _selectedClient = MutableStateFlow<Client?>(null)
    val selectedClient: StateFlow<Client?> = _selectedClient

    fun loadClients() {
        viewModelScope.launch {
            _clients.value = clientUseCases.getClients()
        }
    }

    fun getClientById(id: Int) {
        viewModelScope.launch {
            _selectedClient.value = clientUseCases.getClientById(id)
        }
    }

    fun createClient(client: Client, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = clientUseCases.createClient(client)
            if (result) loadClients()
            onResult(result)
        }
    }

    fun updateClient(client: Client, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = clientUseCases.updateClient(client)
            if (result) loadClients()
            onResult(result)
        }
    }

    fun deleteClient(id: Int, onResult: (Boolean) -> Unit) {
        viewModelScope.launch {
            val result = clientUseCases.deleteClient(id)
            if (result) loadClients()
            onResult(result)
        }
    }
}