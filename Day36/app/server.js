const path = require("path");
const express = require("express");
const mongoose = require("mongoose");
require("dotenv").config();

const app = express();
const startTime = Date.now();

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.log(err));

app.use(express.static(path.join(__dirname, "public")));

// Live status for the dashboard UI
app.get("/api/status", (req, res) => {
  res.json({
    uptimeSeconds: (Date.now() - startTime) / 1000,
    mongoConnected: mongoose.connection.readyState === 1,
  });
});

// Used by the Docker healthcheck
app.get("/api/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
