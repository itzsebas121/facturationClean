const { poolPromise, sql } = require('../db/db');

async function getOrders(clientId = null) {
    try {
        const pool = await poolPromise;
        const request = pool.request();

        if (clientId !== null) {
            request.input('ClientId', sql.Int, clientId);
        }

        const result = await request.execute('getOrders');
        return result.recordset;
    } catch (err) {
        console.error('Error en getOrders:', err);
        throw err;
    }
}

async function createOrder(order) {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('ClientId', sql.Int, order.clientId)
            .execute('CreateOrder');

        return result.recordset[0];
    } catch (err) {
        console.error('Error en createOrder:', err);
        throw err;
    }
}
async function addProductToOrder(orderId, productId, quantity) {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('OrderId', sql.Int, orderId)
            .input('ProductId', sql.Int, productId)
            .input('Quantity', sql.Int, quantity)
            .execute('AddOrUpdateOrderDetail');
        if (result.recordset[0].error) {
            await deleteOrder(orderId);

            return result.recordset[0]
        };
        return result.recordset[0];

    } catch (err) {
        console.error('Error en addProductToOrder:', err);
        throw err;
    }
}
//Pedientes agregarlos a la base de datos
async function getOrderById(orderId) {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('OrderId', sql.Int, orderId)
            .execute('getOrderById');
        return result.recordset;
    }
    catch (err) {
        console.error('Error en getOrderById:', err);
        throw err;
    }
}
async function deleteOrder(orderId) {
    try {
        const pool = await poolPromise;
        await pool.request()
            .input('OrderId', sql.Int, orderId)
            .execute('DeleteOrder');
        return true;
    } catch (err) {
        console.error('Error en deleteOrder:', err);
        throw err;
    }
}
module.exports = {
    getOrders,
    createOrder,
    addProductToOrder,
    getOrderById
};
