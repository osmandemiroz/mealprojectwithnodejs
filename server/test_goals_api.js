/**
 * Test script for the Goals API
 * 
 * This script tests the main endpoints for Goal CRUD operations
 * Run with: node test_goals_api.js
 */

const http = require('http');
const { promisify } = require('util');

// Configuration
const API_HOST = 'localhost';
const API_PORT = 3000;
const API_BASE_PATH = '/api';
const TEST_USER_ID = '1'; // Replace with a valid user ID from your database

// Test data
const testGoal = {
    Goal_Type: 'Weight Loss',
    Start_Date: new Date().toISOString(),
    End_Date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // 30 days from now
    desired_Weight: 75.5,
    start_weight: 80.0,
    number_of_meals_per_day: 3,
    activity_status_per_day: 'Moderate',
    Target_Calories: 2000,
    Target_Protein: 150,
    Target_Carbs: 200,
    Target_Fat: 70,
    UID: TEST_USER_ID
};

// Helper function for making HTTP requests
async function makeRequest(method, path, data = null) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: API_HOST,
            port: API_PORT,
            path: `${API_BASE_PATH}${path}`,
            method: method,
            headers: {
                'Content-Type': 'application/json',
            },
        };

        const req = http.request(options, (res) => {
            let responseData = '';

            res.on('data', (chunk) => {
                responseData += chunk;
            });

            res.on('end', () => {
                try {
                    const parsedData = responseData ? JSON.parse(responseData) : {};
                    resolve({
                        statusCode: res.statusCode,
                        data: parsedData,
                        headers: res.headers
                    });
                } catch (e) {
                    resolve({
                        statusCode: res.statusCode,
                        data: responseData,
                        headers: res.headers
                    });
                }
            });
        });

        req.on('error', (error) => {
            reject(error);
        });

        if (data) {
            req.write(JSON.stringify(data));
        }

        req.end();
    });
}

// Run all tests
async function runTests() {
    console.log('🚀 Starting Goals API Tests');
    let goalId;

    try {
        // 1. Create a new goal
        console.log('\n📝 Testing Goal Creation');
        const createResult = await makeRequest('POST', `/users/${TEST_USER_ID}/goals`, testGoal);
        console.log(`Status: ${createResult.statusCode}`);
        console.log(`Response: ${JSON.stringify(createResult.data, null, 2)}`);

        if (createResult.statusCode !== 201) {
            throw new Error(`Failed to create goal. Status code: ${createResult.statusCode}`);
        }

        goalId = createResult.data.goalId;
        console.log(`✅ Goal created with ID: ${goalId}`);

        // 2. Get all goals for the user
        console.log('\n📋 Testing Get All User Goals');
        const getAllResult = await makeRequest('GET', `/users/${TEST_USER_ID}/goals`);
        console.log(`Status: ${getAllResult.statusCode}`);
        console.log(`Found ${getAllResult.data.length} goals`);

        if (getAllResult.statusCode !== 200) {
            throw new Error(`Failed to get goals. Status code: ${getAllResult.statusCode}`);
        }
        console.log('✅ Successfully retrieved all goals');

        // 3. Get active goals for the user
        console.log('\n🔍 Testing Get Active Goals');
        const getActiveResult = await makeRequest('GET', `/users/${TEST_USER_ID}/goals/active`);
        console.log(`Status: ${getActiveResult.statusCode}`);
        console.log(`Found ${getActiveResult.data.length} active goals`);

        if (getActiveResult.statusCode !== 200) {
            throw new Error(`Failed to get active goals. Status code: ${getActiveResult.statusCode}`);
        }
        console.log('✅ Successfully retrieved active goals');

        // 4. Get a specific goal by ID
        console.log(`\n🔍 Testing Get Goal by ID: ${goalId}`);
        const getOneResult = await makeRequest('GET', `/goals/${goalId}`);
        console.log(`Status: ${getOneResult.statusCode}`);
        console.log(`Goal Type: ${getOneResult.data.Goal_Type}`);

        if (getOneResult.statusCode !== 200) {
            throw new Error(`Failed to get goal. Status code: ${getOneResult.statusCode}`);
        }
        console.log('✅ Successfully retrieved goal by ID');

        // 5. Update the goal
        console.log('\n✏️ Testing Update Goal');
        const updateData = {
            ...testGoal,
            Goal_Type: 'Weight Maintenance',
            desired_Weight: 73.0
        };

        const updateResult = await makeRequest('PUT', `/goals/${goalId}`, updateData);
        console.log(`Status: ${updateResult.statusCode}`);
        console.log(`Response: ${JSON.stringify(updateResult.data, null, 2)}`);

        if (updateResult.statusCode !== 200) {
            throw new Error(`Failed to update goal. Status code: ${updateResult.statusCode}`);
        }
        console.log('✅ Successfully updated goal');

        // 6. Delete the goal
        console.log('\n🗑️ Testing Delete Goal');
        const deleteResult = await makeRequest('DELETE', `/goals/${goalId}`);
        console.log(`Status: ${deleteResult.statusCode}`);
        console.log(`Response: ${JSON.stringify(deleteResult.data, null, 2)}`);

        if (deleteResult.statusCode !== 200) {
            throw new Error(`Failed to delete goal. Status code: ${deleteResult.statusCode}`);
        }
        console.log('✅ Successfully deleted goal');

        console.log('\n🎉 All tests passed successfully!');
    } catch (error) {
        console.error('\n❌ Test failed:', error.message);

        // Cleanup: Try to delete the test goal if it was created
        if (goalId) {
            try {
                console.log(`\n🧹 Cleaning up: Deleting test goal ${goalId}`);
                await makeRequest('DELETE', `/goals/${goalId}`);
            } catch (cleanupError) {
                console.error('Failed to clean up:', cleanupError.message);
            }
        }

        process.exit(1);
    }
}

// Run the tests
runTests();