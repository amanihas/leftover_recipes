import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import dotenv from "dotenv";
import axios from "axios";
import { JSDOM } from "jsdom"; // npm install jsdom

dotenv.config();

const app = express();
const port = 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Test route
app.get("/", (req, res) => {
  res.send("Backend is running!");
});

// Route: Generate recipe suggestions with full steps
app.post("/generate_recipe", async (req, res) => {
  try {
    const { ingredients } = req.body;

    if (!ingredients || ingredients.length === 0) {
      return res.status(400).json({ error: "No ingredients provided" });
    }

    // Step 1: Find recipes by ingredients
    const response = await axios.get(
      `https://api.spoonacular.com/recipes/findByIngredients`,
      {
        params: {
          ingredients: ingredients.join(","), // e.g., "tomato,cheese,bread"
          number: 3, // number of recipes to return
          apiKey: process.env.SPOONACULAR_API_KEY,
        },
      }
    );

    const recipes = response.data;

    // Step 2: Fetch full details for each recipe
    const detailedRecipes = await Promise.all(
      recipes.map(async (r) => {
        const details = await axios.get(
          `https://api.spoonacular.com/recipes/${r.id}/information`,
          {
            params: { apiKey: process.env.SPOONACULAR_API_KEY },
          }
        );

        // Get raw instructions (may include HTML)
        const rawInstructions = details.data.instructions || "";

        // Convert HTML to plain text
        const dom = new JSDOM(rawInstructions);
        const textInstructions = dom.window.document.body.textContent || "";

        // Split into steps array
        const steps = textInstructions
          .split(/\r?\n|\.\s+/)
          .map((s) => s.trim())
          .filter((s) => s.length > 0);

        return {
          id: r.id,
          title: r.title,
          image: r.image,
          usedIngredients: r.usedIngredients,
          missedIngredients: r.missedIngredients,
          steps: steps, // array of step-by-step instructions
        };
      })
    );

    res.json({ recipes: detailedRecipes });
  } catch (error) {
    console.error(
      "🔥 ERROR in /generate_recipe:",
      error.response?.data || error.message
    );
    res.status(500).json({ error: error.message });
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
