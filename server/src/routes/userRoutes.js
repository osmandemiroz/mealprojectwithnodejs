const express = require('express');
const router = express.Router();
const UserController = require('../controllers/userController');

// Register a new user
router.post('/register', UserController.register);

// Get all users
router.get('/', UserController.getAllUsers);

// Get a specific user by ID
router.get('/:uid', UserController.getUser);

// Update a user
router.put('/:uid', UserController.updateUser);

// Delete a user
router.delete('/:uid', UserController.deleteUser);

// Get users managed by an admin
router.get('/admin/:adminUid/managed-users', UserController.getManagedUsers);

module.exports = router; 