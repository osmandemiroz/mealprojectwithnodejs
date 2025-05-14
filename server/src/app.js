// app.js
const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const recipeRoutes = require("./routes/recipe.routes");
const userRoutes = require("./routes/userRoutes");
const goalRoutes = require("./routes/goalRoutes");
const userMealPlanRoutes = require("./routes/userMealPlanRoutes");

dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/recipes", recipeRoutes);
app.use("/api/users", userRoutes);
app.use("/api", goalRoutes);
app.use("/api", userMealPlanRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));