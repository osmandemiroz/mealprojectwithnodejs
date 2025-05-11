const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const db = new sqlite3.Database(path.join(__dirname, '../database/recipe_db_without_insert.db'));

class Goal {
    static async create(goalData) {
        const { goalType, startDate, endDate, targetCalories, targetProtein, targetCarbs, targetFat, uid, desiredWeight, startWeight, numberOfMealsPerDay, activityStatusPerDay } = goalData;

        return new Promise((resolve, reject) => {
            const query = `
                INSERT INTO GOAL (Goal_Type, Start_Date, End_Date, Target_Calories, Target_Protein, 
                                Target_Carbs, Target_Fat, UID, desired_Weight, start_weight, number_of_meals_per_day, activity_status_per_day)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            `;

            db.run(query, [goalType, startDate, endDate, targetCalories, targetProtein,
                targetCarbs, targetFat, uid, desiredWeight, startWeight, numberOfMealsPerDay, activityStatusPerDay
            ], function(err) {
                if (err) reject(err);
                resolve(this.lastID);
            });
        });
    }

    static async findById(gid) {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM GOAL WHERE GID = ?';
            db.get(query, [gid], (err, row) => {
                if (err) reject(err);
                resolve(row);
            });
        });
    }

    static async findByUserId(uid) {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM GOAL WHERE UID = ?';
            db.all(query, [uid], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }

    static async update(gid, goalData) {
        const { goalType, startDate, endDate, targetCalories, targetProtein, targetCarbs, targetFat, desiredWeight, startWeight, numberOfMealsPerDay, activityStatusPerDay } = goalData;

        return new Promise((resolve, reject) => {
            const query = `
                UPDATE GOAL 
                SET Goal_Type = ?, Start_Date = ?, End_Date = ?, 
                    Target_Calories = ?, Target_Protein = ?, Target_Carbs = ?, Target_Fat = ?,
                    desired_weight = ?, start_weight = ?, number_of_meals_per_day = ?, activity_status_per_day = ?
                WHERE GID = ?
            `;

            db.run(query, [goalType, startDate, endDate, targetCalories,
                targetProtein, targetCarbs, targetFat, desiredWeight, startWeight, numberOfMealsPerDay, activityStatusPerDay, gid
            ], function(err) {
                if (err) reject(err);
                resolve(this.changes > 0);
            });
        });
    }

    static async delete(gid) {
        return new Promise((resolve, reject) => {
            const query = 'DELETE FROM GOAL WHERE GID = ?';
            db.run(query, [gid], function(err) {
                if (err) reject(err);
                resolve(this.changes > 0);
            });
        });
    }

    static async getActiveGoals(uid) {
        return new Promise((resolve, reject) => {
            const currentDate = new Date().toISOString();
            const query = `
                SELECT * FROM GOAL 
                WHERE UID = ? AND End_Date >= ?
                ORDER BY Start_Date DESC
            `;
            db.all(query, [uid, currentDate], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }

    static async getCompletedGoals(uid) {
        return new Promise((resolve, reject) => {
            const currentDate = new Date().toISOString();
            const query = `
                SELECT * FROM GOAL 
                WHERE UID = ? AND End_Date < ?
                ORDER BY End_Date DESC
            `;
            db.all(query, [uid, currentDate], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }
}

module.exports = Goal;