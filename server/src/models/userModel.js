const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const db = new sqlite3.Database(path.join(__dirname, '../database/recipe_db_without_insert.db'));

class User {
    static async create(userData) {
        const { name, email, accessLevel, dietaryPreferences } = userData;
        const accountCreationDate = new Date().toISOString();
        
        return new Promise((resolve, reject) => {
            const query = `
                INSERT INTO USER (Account_Creation_Date, Access_Level, Name, Email, Dietary_Preferences)
                VALUES (?, ?, ?, ?, ?)
            `;
            
            db.run(query, [accountCreationDate, accessLevel, name, email, dietaryPreferences], function(err) {
                if (err) reject(err);
                resolve(this.lastID);
            });
        });
    }

    static async findByEmail(email) {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM USER WHERE Email = ?';
            db.get(query, [email], (err, row) => {
                if (err) reject(err);
                resolve(row);
            });
        });
    }

    static async findById(uid) {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM USER WHERE UID = ?';
            db.get(query, [uid], (err, row) => {
                if (err) reject(err);
                resolve(row);
            });
        });
    }

    static async update(uid, userData) {
        const { name, email, accessLevel, dietaryPreferences } = userData;
        
        return new Promise((resolve, reject) => {
            const query = `
                UPDATE USER 
                SET Name = ?, Email = ?, Access_Level = ?, Dietary_Preferences = ?
                WHERE UID = ?
            `;
            
            db.run(query, [name, email, accessLevel, dietaryPreferences, uid], function(err) {
                if (err) reject(err);
                resolve(this.changes > 0);
            });
        });
    }

    static async delete(uid) {
        return new Promise((resolve, reject) => {
            const query = 'DELETE FROM USER WHERE UID = ?';
            db.run(query, [uid], function(err) {
                if (err) reject(err);
                resolve(this.changes > 0);
            });
        });
    }

    static async getAllUsers() {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM USER';
            db.all(query, [], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }

    static async getManagedUsers(adminUid) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT u.* 
                FROM USER u
                JOIN MANAGES m ON u.UID = m.User_UID
                WHERE m.Admin_UID = ?
            `;
            db.all(query, [adminUid], (err, rows) => {
                if (err) reject(err);
                resolve(rows);
            });
        });
    }
}

module.exports = User; 