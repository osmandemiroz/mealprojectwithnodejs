const User = require('../models/userModel');

class UserService {
    static async createUser(userData) {
        // Validate user data
        if (!userData.email || !userData.name) {
            throw new Error('Email and name are required');
        }

        // Check if user already exists
        const existingUser = await User.findByEmail(userData.email);
        if (existingUser) {
            throw new Error('User with this email already exists');
        }

        // Set default access level if not provided
        if (!userData.accessLevel) {
            userData.accessLevel = 'user';
        }

        // Create user
        const userId = await User.create(userData);
        return userId;
    }

    static async getUserById(uid) {
        const user = await User.findById(uid);
        if (!user) {
            throw new Error('User not found');
        }
        return user;
    }

    static async updateUser(uid, userData) {
        // Check if user exists
        const existingUser = await User.findById(uid);
        if (!existingUser) {
            throw new Error('User not found');
        }

        // If email is being updated, check if new email is already in use
        if (userData.email && userData.email !== existingUser.Email) {
            const emailExists = await User.findByEmail(userData.email);
            if (emailExists) {
                throw new Error('Email is already in use');
            }
        }

        // Update user
        const success = await User.update(uid, userData);
        if (!success) {
            throw new Error('Failed to update user');
        }

        return true;
    }

    static async deleteUser(uid) {
        // Check if user exists
        const existingUser = await User.findById(uid);
        if (!existingUser) {
            throw new Error('User not found');
        }

        // Delete user
        const success = await User.delete(uid);
        if (!success) {
            throw new Error('Failed to delete user');
        }

        return true;
    }

    static async getAllUsers() {
        return await User.getAllUsers();
    }

    static async getManagedUsers(adminUid) {
        // Check if admin exists
        const admin = await User.findById(adminUid);
        if (!admin) {
            throw new Error('Admin not found');
        }

        // Check if admin has appropriate access level
        if (admin.Access_Level !== 'admin') {
            throw new Error('User is not an admin');
        }

        return await User.getManagedUsers(adminUid);
    }

    static async validateUserData(userData) {
        const errors = [];

        if (!userData.name) {
            errors.push('Name is required');
        }

        if (!userData.email) {
            errors.push('Email is required');
        } else if (!this.isValidEmail(userData.email)) {
            errors.push('Invalid email format');
        }

        if (userData.accessLevel && !['user', 'admin'].includes(userData.accessLevel)) {
            errors.push('Invalid access level');
        }

        return errors;
    }

    static isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    static async login(email, password) {
        // Validate input
        if (!email || !password) {
            throw new Error('Email and password are required');
        }

        // Attempt to find user with matching credentials
        const user = await User.login(email, password);
        if (!user) {
            throw new Error('Invalid email or password');
        }

        return user;
    }
}

module.exports = UserService; 