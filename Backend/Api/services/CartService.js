const { poolPromise, sql } = require('../db/db');
const { logErrorToDB } = require('./errorLog');

async function getCart(clientID) {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('ClientID', sql.Int, clientID)
            .execute('getCartClient');
        return result.recordset;
    } catch (err) {
        logErrorToDB('CartService', 'getCart', err.message, err.stack);
    }
}

async function insertItem(product) {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('ClientId', sql.Int, product.clientId)
            .input('ProductId', sql.Int, product.productId)
            .input('Quantity', sql.Int, product.quantity)
            .execute('AddItemToCart');

        return result.recordset[0];
    } catch (err) {
        logErrorToDB('CartService', 'insertItem', err.message, err.stack);
    }
}
async function updateProducto(producto) {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('CartId', sql.Int, producto.cartID)
            .input('ProductId', sql.Int, producto.productId)
            .input('Quantity', sql.Int, producto.quantity)
            .execute('UpdateCartItemQuantity');
        return result.recordset?.[0];
    } catch (err) {
        logErrorToDB('CartService', 'updateProducto', err.message, err.stack);
    }
}
async function cartToOrder(cartID) {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('CartId', sql.Int, cartID)
            .execute('ConvertCartToOrder');
        return result.recordset?.[0];
    } catch (err) {
       logErrorToDB('CartService', 'cartToOrder', err.message, err.stack);
    }
}
async function deleteItem(cartID, productID) {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('CartId', sql.Int, cartID)
            .input('ProductId', sql.Int, productID)
            .execute('DeleteCartItem');
        return result.recordset?.[0];
    } catch (err) {
       logErrorToDB('CartService', 'deleteItem', err.message, err.stack);
    }
}
module.exports = {
    getCart,
    insertItem,
    updateProducto,
    cartToOrder,
    deleteItem
};
