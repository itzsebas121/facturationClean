package com.example.shop_car.data.remote.dto

import com.example.shop_car.domain.model.*

fun RoleDto.toDomain(): Role = Role(
    roleId = roleId,
    roleName = roleName
)

fun Role.toDto(): RoleDto = RoleDto(
    roleId = roleId,
    roleName = roleName
)

fun UserDto.toDomain(): User = User(
    userId = userId,
    cedula = cedula,
    email = email,
    passwordHash = passwordHash,
    roleId = roleId,
    registrationDate = registrationDate,
    isBlocked = isBlocked,
    failedLoginAttempts = failedLoginAttempts
)

fun User.toDto(): UserDto = UserDto(
    userId = userId,
    cedula = cedula,
    email = email,
    passwordHash = passwordHash,
    roleId = roleId,
    registrationDate = registrationDate,
    isBlocked = isBlocked,
    failedLoginAttempts = failedLoginAttempts
)

fun ClientDto.toDomain(): Client = Client(
    clientId = clientId,
    userId = userId,
    firstName = firstName,
    lastName = lastName,
    address = address,
    phone = phone
)

fun Client.toDto(): ClientDto = ClientDto(
    clientId = clientId,
    userId = userId,
    firstName = firstName,
    lastName = lastName,
    address = address,
    phone = phone
)

fun AdminDto.toDomain(): Admin = Admin(
    adminId = adminId,
    userId = userId,
    firstName = firstName,
    lastName = lastName,
    address = address ?: "",
    phone = phone ?: ""
)

fun Admin.toDto(): AdminDto = AdminDto(
    adminId = adminId,
    userId = userId,
    firstName = firstName,
    lastName = lastName,
    address = address,
    phone = phone
)

fun CategoryDto.toDomain(): Category = Category(
    categoryId = categoryId,
    categoryName = categoryName
)

fun Category.toDto(): CategoryDto = CategoryDto(
    categoryId = categoryId,
    categoryName = categoryName
)

fun ProductDto.toDomain(): Product = Product(
    productId = productId,
    categoryId = categoryId,
    name = name,
    description = description,
    price = price,
    stock = stock,
    imageUrl = imageUrl
)

fun Product.toDto(): ProductDto = ProductDto(
    productId = productId,
    categoryId = categoryId,
    name = name,
    description = description,
    price = price,
    stock = stock,
    imageUrl = imageUrl
)

fun OrderDto.toDomain(): Order = Order(
    orderId = orderId,
    clientId = clientId,
    orderDate = orderDate,
    total = total,
    subTotal = subTotal,
    tax = tax
)

fun Order.toDto(): OrderDto = OrderDto(
    orderId = orderId,
    clientId = clientId,
    orderDate = orderDate,
    total = total,
    subTotal = subTotal,
    tax = tax
)

fun OrderDetailDto.toDomain(): OrderDetail = OrderDetail(
    orderDetailId = orderDetailId,
    orderId = orderId,
    productId = productId,
    quantity = quantity,
    unitPrice = unitPrice
)

fun OrderDetail.toDto(): OrderDetailDto = OrderDetailDto(
    orderDetailId = orderDetailId,
    orderId = orderId,
    productId = productId,
    quantity = quantity,
    unitPrice = unitPrice
)