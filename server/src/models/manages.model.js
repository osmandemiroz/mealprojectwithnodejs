const db = require('../config/database');

class Manages {
    static async create(adminUid, userUid) {
        const sql = `
            INSERT INTO MANAGES (Admin_UID, User_UID)
            VALUES (?, ?)
        `;
        try {
            const result = await db.run(sql, [adminUid, userUid]);
            return result.lastID;
        } catch (error) {
            throw new Error(`Error creating management relationship: ${error.message}`);
        }
    }

    static async getManagedUsers(adminUid) {
        const sql = `
            SELECT u.*
            FROM MANAGES m
            JOIN USER u ON m.User_UID = u.UID
            WHERE m.Admin_UID = ?
        `;
        try {
            return await db.all(sql, [adminUid]);
        } catch (error) {
            throw new Error(`Error getting managed users: ${error.message}`);
        }
    }

    static async getAdminForUser(userUid) {
        const sql = `
            SELECT u.*
            FROM MANAGES m
            JOIN USER u ON m.Admin_UID = u.UID
            WHERE m.User_UID = ?
        `;
        try {
            return await db.get(sql, [userUid]);
        } catch (error) {
            throw new Error(`Error getting admin for user: ${error.message}`);
        }
    }

    static async delete(adminUid, userUid) {
        const sql = `
            DELETE FROM MANAGES
            WHERE Admin_UID = ? AND User_UID = ?
        `;
        try {
            const result = await db.run(sql, [adminUid, userUid]);
            return result.changes > 0;
        } catch (error) {
            throw new Error(`Error deleting management relationship: ${error.message}`);
        }
    }

    static async exists(adminUid, userUid) {
        const sql = `
            SELECT 1
            FROM MANAGES
            WHERE Admin_UID = ? AND User_UID = ?
        `;
        try {
            const result = await db.get(sql, [adminUid, userUid]);
            return !!result;
        } catch (error) {
            throw new Error(`Error checking management relationship: ${error.message}`);
        }
    }
}

module.exports = Manages; 