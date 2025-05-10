// app.js
const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const recipeRoutes = require("./routes/recipe.routes");
const userRoutes = require("./src/routes/userRoutes");
const goalRoutes = require("./src/routes/goalRoutes");
const progressRoutes = require("./src/routes/progressRoutes");
const alignsWithRoutes = require("./src/routes/alignsWithRoutes");
const createsSavesRoutes = require("./src/routes/createsSaves.routes");
const managesRoutes = require("./src/routes/manages.routes");

dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/recipes", recipeRoutes);
app.use("/api/users", userRoutes);
app.use("/api", goalRoutes);
app.use("/api", progressRoutes);
app.use("/api", alignsWithRoutes);
app.use("/api/creates-saves", createsSavesRoutes);
app.use("/api/manages", managesRoutes);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));