const express = require("express");
const cors = require("cors");
const app = express();
const port = process.env.PORT || 3000;

const productsRouter = require("./routes/Product");
const userRouter = require("./routes/User");
const categoriesRoute = require("./routes/Categorie");
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));
app.use(express.json());

app.use("/api/products", productsRouter);
app.use("/api/user", userRouter);
app.use("/api/categories", categoriesRoute);

app.listen(port, () => {
  console.log(`🚀 Server ready on http://localhost:${port}`);
});
