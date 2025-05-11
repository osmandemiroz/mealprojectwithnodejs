const db = require('../config/database');

const activityFactors = {
    'düşük': 1.2,
    'hafif': 1.375,
    'orta': 1.55,
    'yüksek': 1.725,
    'çok yüksek': 1.9
};

class UserMealPlan {
    static async create(userMealPlanData) {
        const { uid, gid, rid, mealOrderPerDay} = userMealPlanData;

        return new Promise((resolve, reject) => {
            db.run(
                `INSERT INTO USER_MEAL_PLAN (UID, GID, RID, Meal_Order_Per_Day)
                 VALUES (?, ?, ?, ?)`,
                [uid, gid, rid, mealOrderPerDay],
                function(err) {
                    if (err) reject(err);
                    resolve(this.lastID);
                }
            );
        });
    }   

    static async findByUserId(uid) {
        return new Promise((resolve, reject) => {
            db.all(`SELECT * FROM USER_MEAL_PLAN WHERE UID = ?`, [uid], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }

    static async findByGoalId(gid) {
        return new Promise((resolve, reject) => {
            db.all(`SELECT * FROM USER_MEAL_PLAN WHERE GID = ?`, [gid], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }

    static async generateMealPlanForUser(uid) {
        return new Promise((resolve, reject) => {
            db.get(`SELECT * FROM USER WHERE UID = ?`, [uid], (err, userData) => {
                if (err || !userData) return reject(err || 'Kullanıcı bulunamadı');

                db.get(`SELECT * FROM GOAL WHERE UID = ? ORDER BY Start_Date DESC LIMIT 1`, [uid], (err2, goalData) => {
                    if (err2 || !goalData) return reject(err2 || 'Goal bulunamadı');

                    const { Height, Weight } = userData;
                    const { desired_weight, activity_status_per_day, number_of_meals_per_day } = goalData;

                    const bmi = Weight / ((Height / 100) ** 2);
                    const activityFactor = activityFactors[activity_status_per_day.toLowerCase()] || 1.2;

                    const weightDifference = Weight - desired_weight;
                    const calorieAdjustment = weightDifference * 110; // kilo başına günlük kalori farkı
                    const dailyCalories = 2000 + calorieAdjustment; // baz alınan kalori 2000
                    const adjustedCalories = dailyCalories * activityFactor;
                    const caloriesPerMeal = adjustedCalories / number_of_meals_per_day;

                    // Eski planı sil
                    db.run(`DELETE FROM USER_MEAL_PLAN WHERE UID = ? AND GID = ?`, [uid, goalData.GID], (deleteErr) => {
                        if (deleteErr) return reject(deleteErr);

                        // Tarif seçimi
                        const recipeQuery = `
                            SELECT * FROM RECIPE 
                            WHERE calories BETWEEN ? AND ?
                            LIMIT ?
                        `;
                        const calorieRange = 100;

                        db.all(recipeQuery, [caloriesPerMeal - calorieRange, caloriesPerMeal + calorieRange, number_of_meals_per_day * 3 * 7], (err3, recipes) => {
                            if (err3) return reject(err3);
                            if (recipes.length < number_of_meals_per_day * 3 * 7) return reject('Yeterli tarif bulunamadı');

                            const weeklyPlan = [];
                            let recipeIndex = 0;

                            const insertMealPlan = db.prepare(`
                                INSERT INTO USER_MEAL_PLAN (UID, GID, RID, Meal_Order_Per_Day)
                                VALUES (?, ?, ?, ?)
                            `);

                            for (let day = 0; day < 7; day++) {
                                const meals = [];
                                for (let meal = 0; meal < number_of_meals_per_day; meal++) {
                                    const mealRecipes = recipes.slice(recipeIndex, recipeIndex + 3);
                                    meals.push(mealRecipes);

                                    mealRecipes.forEach(recipe => {
                                        insertMealPlan.run(uid, goalData.GID, recipe.RID, meal + 1);
                                    });

                                    recipeIndex += 3;
                                }
                                weeklyPlan.push({ day: day + 1, meals });
                            }

                            insertMealPlan.finalize();

                            resolve({
                                UID: uid,
                                GID: goalData.GID,
                                BMI: bmi.toFixed(2),
                                dailyCalories: adjustedCalories.toFixed(2),
                                caloriesPerMeal: caloriesPerMeal.toFixed(2),
                                weeklyPlan
                            });
                        });
                    });
                });
            });
        });
    }
}

module.exports = UserMealPlan;


    
