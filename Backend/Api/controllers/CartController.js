const cartsService = require('../services/CartService');
const { logErrorToDB } = require('../services/errorLog');

async function getCart(req, res) {
  const { clientID } = req.params;
  try {
    const cart = await cartsService.getCart(clientID);
    res.status(200).json(cart);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener el carrito.' });
    await logErrorToDB('CartController', 'getCart', error.message, error.stack);
  }
}


async function update(req, res) {
  try {
    const result = await cartsService.updateProducto(req.body);

    if (result?.error) {
      res.status(400).json({ error: result.error });
      await logErrorToDB('CartController', 'update', result.error || result.Error,"");
    } else {
      res.status(200).json(result);
    }
  } catch (error) {
    res.status(500).json({ error: 'Error al actualizar el producto del carrito.' });
    await logErrorToDB('CartController', 'update', error.message, error.stack);
  }
}
async function insertItem(req, res) {
  try {
    const result = await cartsService.insertItem(req.body);

    if (result?.error) {
      res.status(400).json({ error: result.error });
      await logErrorToDB('CartController', 'insertItem', result.error || result.Error, "");
    } else {
      res.status(200).json(result);
    }
  } catch (error) {
    res.status(500).json({ error: 'Error al agregar producto al carrito.' });
    await logErrorToDB('CartController', 'insertItem', error.message, error.stack);
  }
}
async function deleteItem(req, res) {
  const { cartID, productID } = req.params;
  try {
    const result = await cartsService.deleteItem(cartID, productID);
    if (!result) {
      res.status(400).json({ error: result.Error });
      await logErrorToDB('CartController', 'deleteItem', result.error || result.Error, '');
    } else {
      res.status(200).json(result);
    }
  } catch (error) {
    res.status(500).json({ error: 'Error al eliminar el producto del carrito.' });
  }
}

async function convertCartToOrder(req, res) {
  const { cartID } = req.body;
  try {
    const result = await cartsService.cartToOrder(cartID);
    if (result?.error) {
      res.status(400).json({ error: result.error });
      await logErrorToDB('CartController', 'convertCartToOrder', result.error || result.Error, '');
    } else {
      res.status(200).json(result);

    }
  }
  catch (error) {
    res.status(500).json({ error: 'Error al convertir el carrito a orden.' });
    await logErrorToDB('CartController', 'convertCartToOrder', error.message, error.stack);
  }
}

module.exports = {
  getCart,
  insertItem,
  update,
  deleteItem,
  convertCartToOrder
};