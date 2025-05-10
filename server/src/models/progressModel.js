const db = require('../config/database');

class Progress {
    static async create(progressData) {
        const { uid, gid, currentWeight, progressPercentage, lastUpdatedDate } = progressData;
        
        return new Promise((resolve, reject) => {
            const query = `
                INSERT INTO TRACKS_PROGRESS (UID, GID, Current_Weight, Progress_Percentage, Last_Updated_Date)
                VALUES (?, ?, ?, ?, ?)
            `;
            
            db.run(query, [uid, gid, currentWeight, progressPercentage, lastUpdatedDate], function(err) {
                if (err) reject(err);
                resolve(this.lastID);
            });
        });
    }

    static async findByUserAndGoal(uid, gid) {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM TRACKS_PROGRESS WHERE UID = ? AND GID = ?';
            db.get(query, [uid, gid], (err, row) => {
                if (err) reject(err);
                resolve(row);
            });
        });
    }

    static async findByUserId(uid) {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM TRACKS_PROGRESS WHERE UID = ?';
            db.all(query, [uid], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }

    static async findByGoalId(gid) {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM TRACKS_PROGRESS WHERE GID = ?';
            db.all(query, [gid], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }

    static async update(uid, gid, progressData) {
        const { currentWeight, progressPercentage, lastUpdatedDate } = progressData;
        
        return new Promise((resolve, reject) => {
            const query = `
                UPDATE TRACKS_PROGRESS 
                SET Current_Weight = ?, Progress_Percentage = ?, Last_Updated_Date = ?
                WHERE UID = ? AND GID = ?
            `;
            
            db.run(query, [currentWeight, progressPercentage, lastUpdatedDate, uid, gid], function(err) {
                if (err) reject(err);
                resolve(this.changes > 0);
            });
        });
    }

    static async delete(uid, gid) {
        return new Promise((resolve, reject) => {
            const query = 'DELETE FROM TRACKS_PROGRESS WHERE UID = ? AND GID = ?';
            db.run(query, [uid, gid], function(err) {
                if (err) reject(err);
                resolve(this.changes > 0);
            });
        });
    }

    static async getLatestProgress(uid) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT tp.*, g.Goal_Type, g.Target_Calories
                FROM TRACKS_PROGRESS tp
                JOIN GOAL g ON tp.GID = g.GID
                WHERE tp.UID = ?
                ORDER BY tp.Last_Updated_Date DESC
                LIMIT 1
            `;
            db.get(query, [uid], (err, row) => {
                if (err) reject(err);
                resolve(row);
            });
        });
    }

    static async getProgressHistory(uid, gid) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT * FROM TRACKS_PROGRESS
                WHERE UID = ? AND GID = ?
                ORDER BY Last_Updated_Date DESC
            `;
            db.all(query, [uid, gid], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }
}

module.exports = Progress; 