const sqlite3 = require('sqlite3').verbose();

const db = new sqlite3.Database('./src/database/recipe_db.db', (err) => {
    if (err) {
        console.error('Error opening database:', err.message);
        return;
    }
    console.log('Connected to the recipe database.');
});

// Get all tables
db.all("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';", [], (err, tables) => {
    if (err) {
        console.error('Error getting tables:', err.message);
        db.close();
        return;
    }
    
    console.log('\nTables in the database:');
    tables.forEach(table => {
        console.log(`\n=== ${table.name} ===`);
        // Get schema for each table
        db.all(`PRAGMA table_info(${table.name});`, [], (err, columns) => {
            if (err) {
                console.error(`Error getting schema for ${table.name}:`, err.message);
            } else {
                columns.forEach(col => {
                    console.log(`${col.name} (${col.type})${col.pk ? ' PRIMARY KEY' : ''}${col.notnull ? ' NOT NULL' : ''}`);
                });
            }
        });
    });
    
    // Close the database after a short delay to allow all queries to complete
    setTimeout(() => {
        db.close();
    }, 1000);
}); 