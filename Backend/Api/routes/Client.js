const express = require('express');
const router = express.Router();
const clientController = require('../controllers/ClientController');
router.get('/', clientController.getAll);

module.exports = router;