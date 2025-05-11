const UserMealPlan = require('../models/userMealPlan');
const db = require('../config/database');

const activityMultiplierMap = {
    "sedentary": 1.2,
    "light": 1.375,
    "moderate": 1.55,
    "active": 1.725,
    "very_active": 1.9
};

const calculateBMI = (weight, height) => {
    return weight / ((height / 100) ** 2);
};

const calculateDailyCalories = (weight, height, age, gender, activityLevel, desiredWeight) => {
    const bmr = gender
        ? 10 * weight + 6.25 * height - 5 * age + 5     // Male
        : 10 * weight + 6.25 * height - 5 * age - 161;  // Female

    const multiplier = activityMultiplierMap[activityLevel] || 1.2;

    const maintenanceCalories = bmr * multiplier;

    if (desiredWeight < weight) {
        return maintenanceCalories - 500;
    } else if (desiredWeight > weight) {
        return maintenanceCalories + 500;
    } else {
        return maintenanceCalories;
    }
};

const recommendRecipes = async (targetCaloriesPerMeal) => {
    return new Promise((resolve, reject) => {
        db.all(
            `SELECT * FROM RECIPE WHERE calories BETWEEN ? AND ? LIMIT 3`,
            [targetCaloriesPerMeal - 100, targetCaloriesPerMeal + 100],
            (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            }
        );
    });
};

const generateMealPlanForUser = async (uid, gid) => {
    const userData = await new Promise((resolve, reject) => {
        db.get(`SELECT * FROM USER WHERE UID = ?`, [uid], (err, row) => {
            if (err) reject(err);
            else resolve(row);
        });
    });

    const goalData = await new Promise((resolve, reject) => {
        db.get(`SELECT * FROM GOAL WHERE GID = ?`, [gid], (err, row) => {
            if (err) reject(err);
            else resolve(row);
        });
    });

    const dailyCalories = calculateDailyCalories(
        userData.Weight,
        userData.Height,
        userData.Age,
        userData.GENDER,
        goalData.activity_status_per_day,
        goalData.desired_weight
    );

    const mealsPerDay = goalData.number_of_meals_per_day;
    const caloriesPerMeal = Math.floor(dailyCalories / mealsPerDay);

    const recipes = await recommendRecipes(caloriesPerMeal);

    for (let mealOrder = 1; mealOrder <= mealsPerDay; mealOrder++) {
        for (const recipe of recipes) {
            await UserMealPlan.create({
                uid,
                gid,
                rid: recipe.RID,
                mealOrderPerDay: mealOrder
            });
        }
    }

    return {
        message: "Meal plan generated successfully.",
        caloriesPerDay: dailyCalories,
        caloriesPerMeal,
        mealsPerDay,
        recipes
    };

};

const getMealPlanForUser = async (uid) => {
    return new Promise((resolve, reject) => {
        const query = `
            SELECT ump.*, r.name AS recipe_name, r.calories 
            FROM USER_MEAL_PLAN ump
            JOIN RECIPE r ON ump.RID = r.RID
            WHERE ump.UID = ?
            ORDER BY ump.Meal_Order_Per_Day ASC
        `;
        db.all(query, [uid], (err, rows) => {
            if (err) reject(err);
            else resolve(rows);
        });
    });
};

module.exports = {
    generateMealPlanForUser,
    getMealPlanForUser // <-- Yeni fonksiyon export edildi
};
