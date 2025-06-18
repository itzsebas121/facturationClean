package com.example.shop_car.di

import com.example.shop_car.data.remote.*
import com.example.shop_car.data.repository.*
import com.example.shop_car.domain.repository.*
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideRetrofit(): Retrofit = Retrofit.Builder()
        .baseUrl("https://facturationclean.vercel.app/")
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    @Provides @Singleton
    fun provideUserApi(retrofit: Retrofit): UserApi = retrofit.create(UserApi::class.java)
    @Provides @Singleton
    fun provideClientApi(retrofit: Retrofit): ClientApi = retrofit.create(ClientApi::class.java)
    @Provides @Singleton
    fun provideAdminApi(retrofit: Retrofit): AdminApi = retrofit.create(AdminApi::class.java)
    @Provides @Singleton
    fun provideCategoryApi(retrofit: Retrofit): CategoryApi = retrofit.create(CategoryApi::class.java)
    @Provides @Singleton
    fun provideOrderApi(retrofit: Retrofit): OrderApi = retrofit.create(OrderApi::class.java)
    @Provides @Singleton
    fun provideOrderDetailApi(retrofit: Retrofit): OrderDetailApi = retrofit.create(OrderDetailApi::class.java)

    @Provides @Singleton
    fun provideUserRepository(api: UserApi): UserRepository = UserRepositoryImpl(api)
    @Provides @Singleton
    fun provideClientRepository(api: ClientApi): ClientRepository = ClientRepositoryImpl(api)
    @Provides @Singleton
    fun provideAdminRepository(api: AdminApi): AdminRepository = AdminRepositoryImpl(api)
    @Provides @Singleton
    fun provideCategoryRepository(api: CategoryApi): CategoryRepository = CategoryRepositoryImpl(api)
    @Provides @Singleton
    fun provideOrderRepository(api: OrderApi): OrderRepository = OrderRepositoryImpl(api)
    @Provides @Singleton
    fun provideOrderDetailRepository(api: OrderDetailApi): OrderDetailRepository = OrderDetailRepositoryImpl(api)
}