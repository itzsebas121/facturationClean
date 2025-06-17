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
module.exports = {
    getAll,
};
