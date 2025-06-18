const express = require("express");
const cors = require("cors");
const app = express();
const port = process.env.PORT || 3000;

const productsRouter = require("./routes/Product");
const userRouter = require("./routes/User");
const categoriesRoute = require("./routes/Categorie");
const clientsRoute = require("./routes/Client");
const ordersRouter = require("./routes/Orders");
/* const cartsRouter = require("./routes/Cart"); */
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));
app.use(express.json());

app.use("/api/products", productsRouter);
app.use("/api/user", userRouter);
app.use("/api/categories", categoriesRoute);
app.use("/api/clients", clientsRoute);
app.use("/api/orders", ordersRouter);
/* app.use("/api/carts", cartsRouter); */

app.listen(port, () => {
  console.log(`🚀 Server ready on http://localhost:${port}`);
});
