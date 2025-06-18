package com.example.shop_car.data.remote

import com.example.shop_car.data.remote.dto.ClientDto
import retrofit2.http.*

interface ClientApi {
    @GET("api/clients")
    suspend fun getClients(): List<ClientDto>

    @GET("api/clients/{id}")
    suspend fun getClientById(@Path("id") id: Int): ClientDto?

    @POST("api/clients")
    suspend fun createClient(@Body client: ClientDto): Boolean

    @PUT("api/clients/{id}")
    suspend fun updateClient(@Path("id") id: Int, @Body client: ClientDto): Boolean

    @DELETE("api/clients/{id}")
    suspend fun deleteClient(@Path("id") id: Int): Boolean
}