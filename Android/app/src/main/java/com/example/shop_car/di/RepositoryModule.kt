package com.example.shop_car.di

import com.example.shop_car.data.remote.ProductApi
import com.example.shop_car.domain.repository.ProductRepository
import com.example.shop_car.data.repository.ProductRepositoryImpl
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton
@Module
@InstallIn(SingletonComponent::class)
object RepositoryModule{
    @Provides
    @Singleton
    fun provideProductRepository(api: ProductApi): ProductRepository =
        ProductRepositoryImpl(api)
}