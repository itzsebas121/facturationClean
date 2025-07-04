const { poolPromise, sql } = require('../db/db');
const { logErrorToDB } = require('./errorLog');

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
       logErrorToDB('OrderService', 'getOrders', err.message, err.stack);
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
       logErrorToDB('OrderService', 'createOrder', err.message, err.stack);
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
        logErrorToDB('OrderService', 'addProductToOrder', err.message, err.stack);
    }
}
async function getOrderById(orderId) {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('OrderId', sql.Int, orderId)
            .execute('getOrderById');
        return result.recordset;
    }
    catch (err) {
        logErrorToDB('OrderService', 'getOrderById', err.message, err.stack);
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
       logErrorToDB('OrderService', 'deleteOrder', err.message, err.stack);
    }
}
async function getNextOrderId() {
    try {
        const pool = await poolPromise;
        const result = await pool.request().query(`
            SELECT IDENT_CURRENT('Orders') + IDENT_INCR('Orders') AS NextOrderID;
        `);

        return result.recordset[0];
    } catch (err) {
        logErrorToDB('OrderService', 'getNextOrderId', err.message, err.stack);
    }
}


module.exports = {
    getOrders,
    createOrder,
    addProductToOrder,
    getOrderById,
    deleteOrder,
    getNextOrderId
};
