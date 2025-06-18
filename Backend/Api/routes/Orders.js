const express = require('express');
const router = express.Router();
const ordersController = require('../controllers/OrderController');

router.get('/', ordersController.getAll);
router.post('/', ordersController.create);
router.post('/addDetail', ordersController.addProductToOrder);

module.exports = router;
