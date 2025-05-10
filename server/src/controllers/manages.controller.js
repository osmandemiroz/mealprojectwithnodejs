const ManagesService = require('../services/manages.service');

class ManagesController {
    static async createManagementRelationship(req, res) {
        try {
            const { adminUid, userUid } = req.body;

            if (!adminUid || !userUid) {
                return res.status(400).json({ error: 'Missing required fields' });
            }

            const result = await ManagesService.createManagementRelationship(adminUid, userUid);
            res.status(201).json({ message: 'Management relationship created successfully', id: result });
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }

    static async getManagedUsers(req, res) {
        try {
            const { adminUid } = req.params;

            if (!adminUid) {
                return res.status(400).json({ error: 'Admin ID is required' });
            }

            const users = await ManagesService.getManagedUsers(adminUid);
            res.json(users);
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }

    static async getAdminForUser(req, res) {
        try {
            const { userUid } = req.params;

            if (!userUid) {
                return res.status(400).json({ error: 'User ID is required' });
            }

            const admin = await ManagesService.getAdminForUser(userUid);
            if (admin) {
                res.json(admin);
            } else {
                res.status(404).json({ error: 'No admin found for this user' });
            }
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }

    static async deleteManagementRelationship(req, res) {
        try {
            const { adminUid, userUid } = req.params;

            if (!adminUid || !userUid) {
                return res.status(400).json({ error: 'Missing required fields' });
            }

            const result = await ManagesService.deleteManagementRelationship(adminUid, userUid);
            
            if (result) {
                res.json({ message: 'Management relationship deleted successfully' });
            } else {
                res.status(404).json({ error: 'Management relationship not found' });
            }
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    }
}

module.exports = ManagesController; 