const ordersService = require('../services/OrderService');


async function getAll(req, res) {
    const { clientId } = req.query;
        try {
        const parsedId = clientId ? parseInt(clientId, 10) : null;
        if (clientId && isNaN(parsedId)) {
            return res.status(400).json({ error: "El clientId debe ser un número válido" });
        }
        const orders = await ordersService.getOrders(parsedId);
        res.status(200).json(orders);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

async function getById(req, res) {
    const { id } = req.params;
    try {
        const order = await ordersService.getOrderById(id);
        if (!order) {
            return res.status(404).json({ error: "Orden no encontrada" });
        }
        res.status(200).json(order);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

async function create(req, res) {
    try {
        const order = req.body;
        const newOrder = await ordersService.createOrder(order);
        if (!newOrder) {
            return res.status(400).json({ create: false });
        }
        res.status(201).json({ create: true, message: "Orden creada exitosamente", orderid: newOrder.OrderId });
    } catch (error) {
        res.status(500).json({ message: "Error al crear producto", error });
    }
}
async function addProductToOrder(req, res) {
    try {
        const { orderId, productId, quantity } = req.body;
        const result = await ordersService.addProductToOrder(orderId, productId, quantity);
        if (result.Message) {
            res.status(200).json({ message: result.Message });
        } else {
            res.status(400).json({ error: result.error || 'Error al agregar el producto a la orden' });
        }
    } catch (error) {
        console.error('Error al agregar el producto a la orden:', error);
        res.status(500).json({ error: error.message || 'Error interno del servidor' });
    }

}
module.exports = {
    getAll,
    create,
    getById,
    addProductToOrder
};
