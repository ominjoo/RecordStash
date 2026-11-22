import express from "express";
import cors from "cors";
import { pool } from "./db.js";


export const app = express();

app.use(cors());
app.use(express.json());

app.get("/api/health", async (req, res) => {
    try {
        await pool.query("SELECT 1");
        return res.json({ status: "ok", db: "up"});
    } catch (error) {
        console.error(error);
        return res.status(503).json({ status: "error", db: "down"});
    }
});

app.use((req, res) => {
    return res.status(404).json({ error: "Not found" });
});

app.use((err, req, res, next) => {
    console.error(err);
    const status = err.status || 500;
    const message = status < 500 ? err.message : "Internal server error";
    return res.status(status).json({ error: message });
});


