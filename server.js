const express = require("express");
const crypto = require("crypto");
const fs = require("fs");

const app = express();
const PORT = 3000;

// KEYS DE TESTE
const keys = new Map([
    ["ABC123", Date.now() + 7 * 24 * 60 * 60 * 1000],
    ["TESTE456", Date.now() + 30 * 24 * 60 * 60 * 1000]
]);

const tokens = new Map();

app.get("/validate", (req, res) => {
    const key = req.query.key;

    if (!key) {
        return res.json({
            valid: false,
            message: "Key não enviada"
        });
    }

    const expiration = keys.get(key);

    if (!expiration) {
        return res.json({
            valid: false,
            message: "Key inválida"
        });
    }

    if (Date.now() > expiration) {
        return res.json({
            valid: false,
            message: "Key expirada"
        });
    }

    const token = crypto.randomBytes(32).toString("hex");

    tokens.set(token, Date.now() + 5 * 60 * 1000);

    res.json({
        valid: true,
        token: token
    });
});

app.get("/script", (req, res) => {
    const token = req.query.token;

    if (!token) {
        return res.status(403).send("Token ausente");
    }

    const expiration = tokens.get(token);

    if (!expiration) {
        return res.status(403).send("Token inválido");
    }

    if (Date.now() > expiration) {
        tokens.delete(token);

        return res.status(403).send("Token expirado");
    }

    tokens.delete(token);

    const script = fs.readFileSync("./main.lua", "utf8");

    res.type("text/plain").send(script);
});

app.listen(PORT, () => {
    console.log(`API rodando em http://localhost:${PORT}`);
});