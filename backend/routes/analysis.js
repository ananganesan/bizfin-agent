const express = require('express');
const router = express.Router();
const openAI = require('../services/openai-service');
const { authenticateToken, checkRole } = require('../middleware/auth');

// Analyze financial query
router.post('/query', authenticateToken, async (req, res) => {
  try {
    const { query, financialData, userRole } = req.body;
    
    if (!query || !userRole) {
      return res.status(400).json({ error: 'Query and user role are required' });
    }

    const analysis = await openAI.analyzeFinancials(financialData, userRole, query);
    
    res.json({
      success: true,
      data: analysis
    });
  } catch (error) {
    console.error('Analysis error:', error);
    res.status(500).json({ error: 'Analysis failed' });
  }
});

// Generate comprehensive report
router.post('/report', authenticateToken, async (req, res) => {
  try {
    const { financialData, userRole } = req.body;
    
    const report = await openAI.generateReport(financialData, userRole);
    
    res.json({
      success: true,
      data: {
        report,
        generatedAt: new Date().toISOString(),
        userRole
      }
    });
  } catch (error) {
    console.error('Report generation error:', error);
    res.status(500).json({ error: 'Report generation failed' });
  }
});

// Get role capabilities
router.get('/capabilities/:role', (req, res) => {
  const { role } = req.params;
  
  const capabilities = {
    'Junior Staff': {
      level: 'Basic',
      features: ['Ask Questions to Reports', 'View Department-specific Analysis'],
      restrictions: ['No Action Plans', 'No Scenario Simulation']
    },
    'Intermediate Staff': {
      level: 'Intermediate',
      features: ['Context-aware responses', 'Basic Action Plans', 'Scenario Simulation'],
      restrictions: ['No Cross-Agent Collaboration']
    },
    'Departmental Head': {
      level: 'Advanced',
      features: ['Autonomous insights', 'Strategic Planning', 'Cross-Agent Collaboration'],
      restrictions: []
    }
  };
  
  res.json(capabilities[role] || capabilities['Junior Staff']);
});

module.exports = router;