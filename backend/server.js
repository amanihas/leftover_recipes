import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import dotenv from "dotenv";
import axios from "axios";

dotenv.config();

const app = express();
const port = 5000;

app.use(cors());
app.use(bodyParser.json({ limit: "10mb" }));

// --------------------
// Detect Ingredients from Image using Google Vision
// --------------------
app.post("/detect_ingredients", async (req, res) => {
  try {
    const { imageBase64 } = req.body;
    if (!imageBase64) {
      return res.status(400).json({ error: "No image provided" });
    }

    const response = await axios.post(
      `https://vision.googleapis.com/v1/images:annotate?key=${process.env.GOOGLE_VISION_API_KEY}`,
      {
        requests: [
          {
            image: { content: imageBase64 },
            features: [{ type: "LABEL_DETECTION", maxResults: 10 }],
          },
        ],
      }
    );

    const labels = response.data.responses[0].labelAnnotations || [];
    const ingredients = labels.map((l) => l.description.toLowerCase());

    res.json({ ingredients });
  } catch (error) {
    console.error(error.response?.data || error.message);
    res.status(500).json({ error: error.message });
  }
});

// --------------------
// Generate Recipes from Ingredients using Spoonacular
// --------------------
app.post("/generate_recipe", async (req, res) => {
  try {
    const { ingredients } = req.body;
    if (!ingredients || ingredients.length === 0) {
      return res.status(400).json({ error: "No ingredients provided" });
    }

    const query = ingredients.join(",");
    const url = `https://api.spoonacular.com/recipes/findByIngredients?ingredients=${encodeURIComponent(
      query
    )}&number=5&ranking=1&ignorePantry=true&apiKey=${process.env.SPOONACULAR_API_KEY}`;

    const response = await axios.get(url);

    // Fetch steps for each recipe
    const recipes = await Promise.all(
      response.data.map(async (r) => {
        let steps = [];
        try {
          const stepsUrl = `https://api.spoonacular.com/recipes/${r.id}/analyzedInstructions?apiKey=${process.env.SPOONACULAR_API_KEY}`;
          const stepsResp = await axios.get(stepsUrl);
          steps = stepsResp.data[0]?.steps?.map((s) => s.step) || [];
        } catch (e) {
          console.error("Failed to fetch steps for recipe id", r.id);
        }

        return {
          id: r.id,
          title: r.title,
          image: r.image,
          usedIngredients: r.usedIngredients,
          missedIngredients: r.missedIngredients,
          steps,
        };
      })
    );

    res.json({ recipes });
  } catch (error) {
    console.error(error.response?.data || error.message);
    res.status(500).json({ error: error.message });
  }
});


app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
