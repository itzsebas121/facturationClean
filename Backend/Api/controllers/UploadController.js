const multer = require('multer');
const { uploadImageFromBuffer } = require('../services/UploadService');

const storage = multer.memoryStorage();
const upload = multer({ storage });

function runMiddleware(req, res, fn) {
  return new Promise((resolve, reject) => {
    fn(req, res, (result) => {
      if (result instanceof Error) reject(result);
      else resolve(result);
    });
  });
}

async function uploadHandler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  try {
    await runMiddleware(req, res, upload.single('file'));

    if (!req.file) {
      return res.status(400).json({ error: 'No se subió ningún archivo' });
    }

    const result = await uploadImageFromBuffer(req.file.buffer, 'usuarios');
    return res.status(200).json({ imageUrl: result.secure_url });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: 'Error al subir la imagen', details: error.message });
  }
}

module.exports = {
  uploadHandler,
};
