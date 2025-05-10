const express = require('express');
const router = express.Router();
const AlignsWithController = require('../controllers/alignsWithController');

// Create alignment between goal and recipe
router.post('/goals/:gid/recipes/:rid/align', AlignsWithController.createAlignment);

// Update alignment compatibility score
router.put('/goals/:gid/recipes/:rid/align', AlignsWithController.updateAlignment);

// Delete alignment
router.delete('/goals/:gid/recipes/:rid/align', AlignsWithController.deleteAlignment);

// Get specific alignment
router.get('/goals/:gid/recipes/:rid/align', AlignsWithController.getAlignment);

// Get all alignments for a goal
router.get('/goals/:gid/alignments', AlignsWithController.getGoalAlignments);

// Get all alignments for a recipe
router.get('/recipes/:rid/alignments', AlignsWithController.getRecipeAlignments);

// Get top compatible recipes for a goal
router.get('/goals/:gid/compatible-recipes', AlignsWithController.getTopCompatibleRecipes);

// Get compatible goals for a recipe
router.get('/recipes/:rid/compatible-goals', AlignsWithController.getCompatibleGoals);

module.exports = router; 