const db = require('../config/database');

class CreatesSaves {
    static async create(uid, rid, creationDate, saveDate = null, isFavorite = false) {
        const sql = `
            INSERT INTO CREATES_SAVES (UID, RID, Creation_Date, Save_Date, IsFavorite)
            VALUES (?, ?, ?, ?, ?)
        `;
        try {
            const result = await db.run(sql, [uid, rid, creationDate, saveDate, isFavorite ? 1 : 0]);
            return result.lastID;
        } catch (error) {
            throw new Error(`Error creating recipe save: ${error.message}`);
        }
    }

    static async getByUserId(uid) {
        const sql = `
            SELECT cs.*, r.*
            FROM CREATES_SAVES cs
            JOIN RECIPE r ON cs.RID = r.RID
            WHERE cs.UID = ?
        `;
        try {
            return await db.all(sql, [uid]);
        } catch (error) {
            throw new Error(`Error getting user's recipes: ${error.message}`);
        }
    }

    static async getFavorites(uid) {
        const sql = `
            SELECT cs.*, r.*
            FROM CREATES_SAVES cs
            JOIN RECIPE r ON cs.RID = r.RID
            WHERE cs.UID = ? AND cs.IsFavorite = 1
        `;
        try {
            return await db.all(sql, [uid]);
        } catch (error) {
            throw new Error(`Error getting user's favorite recipes: ${error.message}`);
        }
    }

    static async updateSaveDate(uid, rid, saveDate) {
        const sql = `
            UPDATE CREATES_SAVES
            SET Save_Date = ?
            WHERE UID = ? AND RID = ?
        `;
        try {
            const result = await db.run(sql, [saveDate, uid, rid]);
            return result.changes > 0;
        } catch (error) {
            throw new Error(`Error updating save date: ${error.message}`);
        }
    }

    static async toggleFavorite(uid, rid) {
        const sql = `
            UPDATE CREATES_SAVES
            SET IsFavorite = CASE WHEN IsFavorite = 1 THEN 0 ELSE 1 END
            WHERE UID = ? AND RID = ?
        `;
        try {
            const result = await db.run(sql, [uid, rid]);
            return result.changes > 0;
        } catch (error) {
            throw new Error(`Error toggling favorite status: ${error.message}`);
        }
    }

    static async delete(uid, rid) {
        const sql = `
            DELETE FROM CREATES_SAVES
            WHERE UID = ? AND RID = ?
        `;
        try {
            const result = await db.run(sql, [uid, rid]);
            return result.changes > 0;
        } catch (error) {
            throw new Error(`Error deleting recipe save: ${error.message}`);
        }
    }
}

module.exports = CreatesSaves; 