const db = require('../config/database');

class User {
    static async findById(uid) {
        return new Promise((resolve, reject) => {
            db.get('SELECT * FROM USER WHERE UID = ?', [uid], (err, row) => {
                if (err) reject(err);
                resolve(row);
            });
        });
    }

    static async findByEmail(email) {
        return new Promise((resolve, reject) => {
            db.get('SELECT * FROM USER WHERE Email = ?', [email], (err, row) => {
                if (err) reject(err);
                resolve(row);
            });
        });
    }

    static async create(userData) {
        const { Name, Email, Dietary_Preferences, Access_Level } = userData;
        return new Promise((resolve, reject) => {
            db.run(
                'INSERT INTO USER (Name, Email, Dietary_Preferences, Access_Level, Account_Creation_Date) VALUES (?, ?, ?, ?, date("now"))',
                [Name, Email, Dietary_Preferences, Access_Level],
                function(err) {
                    if (err) reject(err);
                    resolve(this.lastID);
                }
            );
        });
    }

    static async update(uid, userData) {
        const { Name, Email, Dietary_Preferences, Access_Level } = userData;
        return new Promise((resolve, reject) => {
            db.run(
                'UPDATE USER SET Name = ?, Email = ?, Dietary_Preferences = ?, Access_Level = ? WHERE UID = ?',
                [Name, Email, Dietary_Preferences, Access_Level, uid],
                function(err) {
                    if (err) reject(err);
                    resolve(this.changes);
                }
            );
        });
    }

    static async delete(uid) {
        return new Promise((resolve, reject) => {
            db.run('DELETE FROM USER WHERE UID = ?', [uid], function(err) {
                if (err) reject(err);
                resolve(this.changes);
            });
        });
    }
}

module.exports = User; 