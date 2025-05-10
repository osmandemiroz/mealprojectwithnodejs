const Manages = require('../models/manages.model');
const User = require('../models/user.model');

class ManagesService {
    static async createManagementRelationship(adminUid, userUid) {
        // Validate admin exists and has admin privileges
        const admin = await User.getById(adminUid);
        if (!admin) {
            throw new Error('Admin user not found');
        }
        if (admin.Access_Level !== 'admin') {
            throw new Error('User does not have admin privileges');
        }

        // Validate user exists
        const user = await User.getById(userUid);
        if (!user) {
            throw new Error('User not found');
        }

        // Check if relationship already exists
        const exists = await Manages.exists(adminUid, userUid);
        if (exists) {
            throw new Error('Management relationship already exists');
        }

        // Prevent self-management
        if (adminUid === userUid) {
            throw new Error('Admin cannot manage themselves');
        }

        return await Manages.create(adminUid, userUid);
    }

    static async getManagedUsers(adminUid) {
        // Validate admin exists and has admin privileges
        const admin = await User.getById(adminUid);
        if (!admin) {
            throw new Error('Admin user not found');
        }
        if (admin.Access_Level !== 'admin') {
            throw new Error('User does not have admin privileges');
        }

        return await Manages.getManagedUsers(adminUid);
    }

    static async getAdminForUser(userUid) {
        // Validate user exists
        const user = await User.getById(userUid);
        if (!user) {
            throw new Error('User not found');
        }

        return await Manages.getAdminForUser(userUid);
    }

    static async deleteManagementRelationship(adminUid, userUid) {
        // Validate admin exists and has admin privileges
        const admin = await User.getById(adminUid);
        if (!admin) {
            throw new Error('Admin user not found');
        }
        if (admin.Access_Level !== 'admin') {
            throw new Error('User does not have admin privileges');
        }

        // Validate user exists
        const user = await User.getById(userUid);
        if (!user) {
            throw new Error('User not found');
        }

        // Check if relationship exists
        const exists = await Manages.exists(adminUid, userUid);
        if (!exists) {
            throw new Error('Management relationship does not exist');
        }

        return await Manages.delete(adminUid, userUid);
    }
}

module.exports = ManagesService; 