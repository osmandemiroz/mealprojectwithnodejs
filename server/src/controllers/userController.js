const UserService = require('../services/userService');

class UserController {
    static async register(req, res) {
        try {
            const { name, email, accessLevel, dietaryPreferences } = req.body;
            
            // Validate user data
            const validationErrors = await UserService.validateUserData(req.body);
            if (validationErrors.length > 0) {
                return res.status(400).json({ message: 'Validation failed', errors: validationErrors });
            }

            // Create new user
            const userId = await UserService.createUser({
                name,
                email,
                accessLevel,
                dietaryPreferences
            });

            res.status(201).json({
                message: 'User created successfully',
                userId
            });
        } catch (error) {
            if (error.message.includes('already exists')) {
                return res.status(400).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error creating user', error: error.message });
        }
    }

    static async getUser(req, res) {
        try {
            const { uid } = req.params;
            const user = await UserService.getUserById(uid);
            res.json(user);
        } catch (error) {
            if (error.message === 'User not found') {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching user', error: error.message });
        }
    }

    static async updateUser(req, res) {
        try {
            const { uid } = req.params;
            const { name, email, accessLevel, dietaryPreferences } = req.body;

            // Validate user data
            const validationErrors = await UserService.validateUserData(req.body);
            if (validationErrors.length > 0) {
                return res.status(400).json({ message: 'Validation failed', errors: validationErrors });
            }

            await UserService.updateUser(uid, {
                name,
                email,
                accessLevel,
                dietaryPreferences
            });

            res.json({ message: 'User updated successfully' });
        } catch (error) {
            if (error.message === 'User not found') {
                return res.status(404).json({ message: error.message });
            }
            if (error.message.includes('already in use')) {
                return res.status(400).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error updating user', error: error.message });
        }
    }

    static async deleteUser(req, res) {
        try {
            const { uid } = req.params;
            await UserService.deleteUser(uid);
            res.json({ message: 'User deleted successfully' });
        } catch (error) {
            if (error.message === 'User not found') {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error deleting user', error: error.message });
        }
    }

    static async getAllUsers(req, res) {
        try {
            const users = await UserService.getAllUsers();
            res.json(users);
        } catch (error) {
            res.status(500).json({ message: 'Error fetching users', error: error.message });
        }
    }

    static async getManagedUsers(req, res) {
        try {
            const { adminUid } = req.params;
            const users = await UserService.getManagedUsers(adminUid);
            res.json(users);
        } catch (error) {
            if (error.message === 'Admin not found') {
                return res.status(404).json({ message: error.message });
            }
            if (error.message === 'User is not an admin') {
                return res.status(403).json({ message: error.message });
            }
            res.status(500).json({ message: 'Error fetching managed users', error: error.message });
        }
    }
}

module.exports = UserController; 