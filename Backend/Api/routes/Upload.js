const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/UploadController');
router.post('/', uploadController.uploadHandler);
module.exports = router; 