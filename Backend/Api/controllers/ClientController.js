const clientService = require("../services/ClientService.js")

async function getAll(req, res) {
    try {
        const clients = await clientService.getAllClients();
        res.json(clients);
    }
    catch (error) {
        console.error("❌ Error al obtener clientes:", error);
        res.status(500).json({ message: "Error al obtener clientes", error });
    }
}
async function create(req, res) {
    try {
        const client = req.body;
        const newClient = await clientService.createClient(client);
        res.status(201).json(newClient);
    }
    catch (error) {
        res.status(500).json({ message: "Error al crear cliente", error });
    }
}
module.exports = {
    getAll,
    create,
};
