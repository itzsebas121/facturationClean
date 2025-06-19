const cartsService = require('../services/cartservice');

async function getCart(req, res) {
  const { clientID } = req.params;
  try {
    const cart = await cartsService.getCart(clientID);
    res.status(200).json(cart);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener el carrito.' });
  }
}


async function update(req, res) {
  try {
    const result = await cartsService.updateProducto(req.body);

    if (result?.error) {
      res.status(400).json({ error: result.error });
    } else {
      res.status(200).json(result);
    }
  } catch (error) {
    res.status(500).json({ error: 'Error al actualizar el producto del carrito.' });
  }
}
async function insertItem(req, res) {
  try {
    const result = await cartsService.insertItem(req.body);

    if (result?.error) {
      res.status(400).json({ error: result.error });
    } else {
      res.status(200).json(result);
    }
  } catch (error) {
    res.status(500).json({ error: 'Error al agregar producto al carrito.' });
  }
}

async function convertCartToOrder(req, res) {
  const { cartID } = req.body;
  try {
    const result = await cartsService.cartToOrder(cartID);
    if (result?.error) {
      res.status(400).json({ error: result.error });
    } else {
      res.status(200).json(result);
    }
  }
  catch (error) {
    res.status(500).json({ error: 'Error al convertir el carrito a orden.' });
  }
}

module.exports = {
  getCart,
  insertItem,
  update,
  convertCartToOrder
};