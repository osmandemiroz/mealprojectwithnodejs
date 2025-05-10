const db = require('../config/database');

class Goal {
    static async findById(gid) {
        return new Promise((resolve, reject) => {
            db.get('SELECT * FROM GOAL WHERE GID = ?', [gid], (err, row) => {
                if (err) reject(err);
                resolve(row);
            });
        });
    }

    static async findByUserId(uid) {
        return new Promise((resolve, reject) => {
            db.all('SELECT * FROM GOAL WHERE UID = ?', [uid], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }

    static async create(goalData) {
        const {
            UID,
            Goal_Type,
            Start_Date,
            End_Date,
            Target_Calories,
            Target_Protein,
            Target_Carbs,
            Target_Fat
        } = goalData;

        return new Promise((resolve, reject) => {
            db.run(
                `INSERT INTO GOAL (
                    UID, Goal_Type, Start_Date, End_Date,
                    Target_Calories, Target_Protein, Target_Carbs, Target_Fat
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                [UID, Goal_Type, Start_Date, End_Date, Target_Calories, Target_Protein, Target_Carbs, Target_Fat],
                function(err) {
                    if (err) reject(err);
                    resolve(this.lastID);
                }
            );
        });
    }

    static async update(gid, goalData) {
        const {
            Goal_Type,
            Start_Date,
            End_Date,
            Target_Calories,
            Target_Protein,
            Target_Carbs,
            Target_Fat
        } = goalData;

        return new Promise((resolve, reject) => {
            db.run(
                `UPDATE GOAL SET 
                    Goal_Type = ?, Start_Date = ?, End_Date = ?,
                    Target_Calories = ?, Target_Protein = ?, Target_Carbs = ?, Target_Fat = ?
                WHERE GID = ?`,
                [Goal_Type, Start_Date, End_Date, Target_Calories, Target_Protein, Target_Carbs, Target_Fat, gid],
                function(err) {
                    if (err) reject(err);
                    resolve(this.changes);
                }
            );
        });
    }

    static async delete(gid) {
        return new Promise((resolve, reject) => {
            db.run('DELETE FROM GOAL WHERE GID = ?', [gid], function(err) {
                if (err) reject(err);
                resolve(this.changes);
            });
        });
    }
}

module.exports = Goal; 