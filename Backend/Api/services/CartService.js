const { poolPromise, sql } = require('../db/db');

async function getCart(clientID) {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('ClientID', sql.Int, clientID)
            .execute('getCartClient');
        return result.recordset;
    } catch (err) {
        console.error("Error en getCart:", err);
        throw err;
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
        console.error("Error en insertItem:", err);
        throw err;
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
        console.error("Error en updateProducto:", err);
        throw err;
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
        console.error("Error en cartToOrder:", err);
        throw err;
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
        console.error("Error en deleteItem:", err);
        throw err;
    }
}
module.exports = {
    getCart,
    insertItem,
    updateProducto,
    cartToOrder,
    deleteItem
};
