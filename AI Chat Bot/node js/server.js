const express = require("express");
const axios = require("axios");
const path = require("path");
require("dotenv").config();
// for privacy 
const app = express();
const PORT = 3000;

app.use(express.json());
app.use(express.static("public"));

const API_KEY = process.env.API_KEY;

app.post("/api/chat", async (req, res) => {
    const userMessage = req.body.message;

    try {
        const response = await axios.post(
            "https://openrouter.ai/api/v1/chat/completions",
            {
                model: "z-ai/glm-4.5-air:free", // switch models (see models on openrouter)
                messages: [
                    {
                        role: "user",
                        content: userMessage
                    }
                ]
            },
            {
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${API_KEY}`,
                    "HTTP-Referer": "http://localhost:3000", // local server + internet required
                    "X-Title": "MyChatApp"
                },
                timeout: 10000
            }
        );

        const reply = response.data.choices[0].message.content;
        res.json({ reply });
    } catch (error) {
        if (error.response) {
            console.error("OpenRouter API error:", error.response.status, error.response.data);
            res.status(500).json({ reply: `API ERROR 400: ${JSON.stringify(error.response.data)}` });
        } else if (error.request) {
            console.error("No response received:", error.message);
            res.status(500).json({ reply: "No responses from the server!" });
        } else {
            console.error("Axios error:", error.message);
            res.status(500).json({ reply: "Oopsie! An error occured." });
        }
    }
});

app.listen(PORT, () => {
    console.log(`Server succesfully running at http://localhost:${PORT}`);
});
