const db = require('../config/database');

class AlignsWith {
    static async create(alignmentData) {
        const { gid, rid, compatibilityScore } = alignmentData;
        
        return new Promise((resolve, reject) => {
            const query = `
                INSERT INTO ALIGNS_WITH (GID, RID, Compatibility_Score)
                VALUES (?, ?, ?)
            `;
            
            db.run(query, [gid, rid, compatibilityScore], function(err) {
                if (err) reject(err);
                resolve(this.lastID);
            });
        });
    }

    static async findByGoalAndRecipe(gid, rid) {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM ALIGNS_WITH WHERE GID = ? AND RID = ?';
            db.get(query, [gid, rid], (err, row) => {
                if (err) reject(err);
                resolve(row);
            });
        });
    }

    static async findByGoal(gid) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT a.*, r.title, r.calories, r.protein_g, r.carbohydrates_g, r.fat_g
                FROM ALIGNS_WITH a
                JOIN RECIPE r ON a.RID = r.RID
                WHERE a.GID = ?
                ORDER BY a.Compatibility_Score DESC
            `;
            db.all(query, [gid], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }

    static async findByRecipe(rid) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT a.*, g.Goal_Type, g.Target_Calories
                FROM ALIGNS_WITH a
                JOIN GOAL g ON a.GID = g.GID
                WHERE a.RID = ?
                ORDER BY a.Compatibility_Score DESC
            `;
            db.all(query, [rid], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }

    static async update(gid, rid, compatibilityScore) {
        return new Promise((resolve, reject) => {
            const query = `
                UPDATE ALIGNS_WITH 
                SET Compatibility_Score = ?
                WHERE GID = ? AND RID = ?
            `;
            
            db.run(query, [compatibilityScore, gid, rid], function(err) {
                if (err) reject(err);
                resolve(this.changes > 0);
            });
        });
    }

    static async delete(gid, rid) {
        return new Promise((resolve, reject) => {
            const query = 'DELETE FROM ALIGNS_WITH WHERE GID = ? AND RID = ?';
            db.run(query, [gid, rid], function(err) {
                if (err) reject(err);
                resolve(this.changes > 0);
            });
        });
    }

    static async getTopCompatibleRecipes(gid, limit = 5) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT a.*, r.title, r.calories, r.protein_g, r.carbohydrates_g, r.fat_g
                FROM ALIGNS_WITH a
                JOIN RECIPE r ON a.RID = r.RID
                WHERE a.GID = ?
                ORDER BY a.Compatibility_Score DESC
                LIMIT ?
            `;
            db.all(query, [gid, limit], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }

    static async getCompatibleGoals(rid, minScore = 3) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT a.*, g.Goal_Type, g.Target_Calories
                FROM ALIGNS_WITH a
                JOIN GOAL g ON a.GID = g.GID
                WHERE a.RID = ? AND a.Compatibility_Score >= ?
                ORDER BY a.Compatibility_Score DESC
            `;
            db.all(query, [rid, minScore], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }
}

module.exports = AlignsWith; 