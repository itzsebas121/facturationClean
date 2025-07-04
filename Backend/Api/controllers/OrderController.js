const ordersService = require('../services/OrderService');
const { logErrorToDB } = require('../services/errorLog');

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
            
            logErrorToDB("OrderController","getById",order.error||order.Error||`No se encontró la orden con ID ${id}`, "");
            return res.status(404).json({ error: "Orden no encontrada" });
        }
        res.status(200).json(order);
    } catch (error) {
        logErrorToDB("OrderController","getById",error.message, error.stack);
        res.status(500).json({ error: error.message });
    }
}

async function create(req, res) {
    try {
        const order = req.body;
        const newOrder = await ordersService.createOrder(order);
        if (!newOrder) {
            logErrorToDB("OrderController","create",newOrder.error||newOrder.Error||"Error al crear la orden", "");
            return res.status(400).json({ create: false });
        }
        res.status(201).json({ create: true, message: "Orden creada exitosamente", orderid: newOrder.OrderId });
    } catch (error) {
        logErrorToDB("OrderController","create",error.message, error.stack);
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
            logErrorToDB("OrderController","addProductToOrder",result.error||result.ERROR||result.Error||"Error al agregar el producto a la orden", "");
            res.status(400).json({ error: result.error || 'Error al agregar el producto a la orden' });
        }
    } catch (error) {
        logErrorToDB("OrderController","addProductToOrder",error.message, error.stack);
        res.status(500).json({ error: error.message || 'Error interno del servidor' });
    }

}
async function getNextOrderId(req, res) {
    try {
        const result = await ordersService.getNextOrderId();
        res.status(200).json(result);
    } catch (error) {
        logErrorToDB('OrderController', 'getNextOrderId', error.message, error.stack);
        res.status(500).json({ message: "Error al obtener el siguiente número de orden." });
    }
}


module.exports = {
    getAll,
    create,
    getById,
    addProductToOrder,
    getNextOrderId,
};
