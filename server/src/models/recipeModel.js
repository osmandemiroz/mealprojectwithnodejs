// src/models/recipeModel.js
const db = require('../config/database');

const recipeModel = {
  getAll: () => {
    return new Promise((resolve, reject) => {
      db.all("SELECT * FROM RECIPE", [], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  },

  getById: (id) => {
    return new Promise((resolve, reject) => {
      db.get("SELECT * FROM RECIPE WHERE RID = ?", [id], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });
  },

  create: (data) => {
    const fields = Object.keys(data).join(", ");
    const placeholders = Object.keys(data).map(() => "?").join(", ");
    const values = Object.values(data);

    return new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO RECIPE (${fields}) VALUES (${placeholders})`,
        values,
        function (err) {
          if (err) reject(err);
          else resolve({ id: this.lastID });
        }
      );
    });
  },

  delete: (id) => {
    return new Promise((resolve, reject) => {
      db.run("DELETE FROM RECIPE WHERE RID = ?", [id], function (err) {
        if (err) reject(err);
        else resolve({ changes: this.changes });
      });
    });
  },
};

module.exports = recipeModel;
