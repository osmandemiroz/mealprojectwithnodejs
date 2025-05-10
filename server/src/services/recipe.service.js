const db = require('../config/database');

class RecipeService {
    // Basic CRUD Operations
    static async getAllRecipes() {
        return new Promise((resolve, reject) => {
            db.all("SELECT * FROM RECIPE", [], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    static async getRecipeById(recipeId) {
        return new Promise((resolve, reject) => {
            db.get("SELECT * FROM RECIPE WHERE RID = ?", [recipeId], (err, row) => {
                if (err) reject(err);
                else resolve(row);
            });
        });
    }

    // Advanced Search Queries
    static async searchRecipesByTitle(title) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT * FROM RECIPE 
                WHERE title LIKE ? 
                ORDER BY title ASC
            `;
            db.all(query, [`%${title}%`], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    static async getRecipesByCategory(category) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT * FROM RECIPE 
                WHERE category = ? 
                ORDER BY title ASC
            `;
            db.all(query, [category], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    // Nutritional Queries
    static async getLowCalorieRecipes(maxCalories = 300) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT * FROM RECIPE 
                WHERE calories <= ? 
                ORDER BY calories ASC
            `;
            db.all(query, [maxCalories], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    static async getHighProteinRecipes(minProtein = 20) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT * FROM RECIPE 
                WHERE protein_g >= ? 
                ORDER BY protein_g DESC
            `;
            db.all(query, [minProtein], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    static async getLowCarbRecipes(maxCarbs = 30) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT * FROM RECIPE 
                WHERE carbohydrates_g <= ? 
                ORDER BY carbohydrates_g ASC
            `;
            db.all(query, [maxCarbs], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    // Time-based Queries
    static async getQuickRecipes(maxPrepTime = 15) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT * FROM RECIPE 
                WHERE prep_time <= ? 
                ORDER BY prep_time ASC
            `;
            db.all(query, [maxPrepTime], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    static async getRecipesByTotalTime(maxTotalTime = 30) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT * FROM RECIPE 
                WHERE total_time <= ? 
                ORDER BY total_time ASC
            `;
            db.all(query, [maxTotalTime], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    // Complex Nutritional Queries
    static async getBalancedMeals(minProtein = 15, maxCarbs = 40, maxFat = 20) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT * FROM RECIPE 
                WHERE protein_g >= ? 
                AND carbohydrates_g <= ? 
                AND fat_g <= ?
                ORDER BY calories ASC
            `;
            db.all(query, [minProtein, maxCarbs, maxFat], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    static async getHighFiberRecipes(minFiber = 5) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT * FROM RECIPE 
                WHERE dietary_fiber_g >= ? 
                ORDER BY dietary_fiber_g DESC
            `;
            db.all(query, [minFiber], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    // Pagination and Sorting
    static async getPaginatedRecipes(page = 1, limit = 10, sortBy = 'title', order = 'ASC') {
        return new Promise((resolve, reject) => {
            const offset = (page - 1) * limit;
            const query = `
                SELECT * FROM RECIPE 
                ORDER BY ${sortBy} ${order}
                LIMIT ? OFFSET ?
            `;
            db.all(query, [limit, offset], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    // Advanced Filtering
    static async getRecipesByMultipleCategories(categories) {
        return new Promise((resolve, reject) => {
            const placeholders = categories.map(() => '?').join(',');
            const query = `
                SELECT * FROM RECIPE 
                WHERE category IN (${placeholders})
                ORDER BY category, title
            `;
            db.all(query, categories, (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    static async getRecipesByNutritionalRange(minCalories, maxCalories, minProtein, maxProtein) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT * FROM RECIPE 
                WHERE calories BETWEEN ? AND ?
                AND protein_g BETWEEN ? AND ?
                ORDER BY calories ASC
            `;
            db.all(query, [minCalories, maxCalories, minProtein, maxProtein], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    // Statistical Queries
    static async getAverageNutritionalValues() {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT 
                    AVG(calories) as avg_calories,
                    AVG(protein_g) as avg_protein,
                    AVG(carbohydrates_g) as avg_carbs,
                    AVG(fat_g) as avg_fat,
                    AVG(dietary_fiber_g) as avg_fiber
                FROM RECIPE
            `;
            db.get(query, [], (err, row) => {
                if (err) reject(err);
                else resolve(row);
            });
        });
    }

    static async getRecipeCountByCategory() {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT category, COUNT(*) as count
                FROM RECIPE
                GROUP BY category
                ORDER BY count DESC
            `;
            db.all(query, [], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    // Search by Ingredients
    static async searchRecipesByIngredient(ingredient) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT * FROM RECIPE 
                WHERE LOWER(ingredients) LIKE LOWER(?)
                ORDER BY title ASC
            `;
            db.all(query, [`%${ingredient}%`], (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }
}

module.exports = RecipeService; 