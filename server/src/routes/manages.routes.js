const express = require('express');
const router = express.Router();
const ManagesController = require('../controllers/manages.controller');

// Create a new management relationship
router.post('/', ManagesController.createManagementRelationship);

// Get all users managed by an admin
router.get('/admin/:adminUid/users', ManagesController.getManagedUsers);

// Get admin for a specific user
router.get('/user/:userUid/admin', ManagesController.getAdminForUser);

// Delete a management relationship
router.delete('/:adminUid/:userUid', ManagesController.deleteManagementRelationship);

module.exports = router; 