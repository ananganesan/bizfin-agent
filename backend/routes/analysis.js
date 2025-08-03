const express = require('express');
const router = express.Router();
const openAI = require('../services/openai-service');
const vectorService = require('../services/vector-service');
const { authenticateToken, checkRole } = require('../middleware/auth');

// Analyze financial query
router.post('/query', authenticateToken, async (req, res) => {
  try {
    const { query, financialData, userRole } = req.body;
    
    if (!query || !userRole) {
      return res.status(400).json({ error: 'Query and user role are required' });
    }

    // Try to use RAG if we have a vector document ID
    let enhancedFinancialData = financialData;
    
    if (financialData && financialData.vectorDocumentId) {
      try {
        // Search for relevant chunks using the query
        const relevantChunks = await vectorService.searchRelevantChunks(query, 5);
        
        if (relevantChunks && relevantChunks.length > 0) {
          // Combine the relevant chunks with the original data
          enhancedFinancialData = {
            ...financialData,
            relevantContext: relevantChunks.map(chunk => ({
              text: chunk.text,
              score: chunk.score,
              metadata: chunk.metadata
            }))
          };
        }
      } catch (ragError) {
        console.error('RAG retrieval error:', ragError);
        // Continue with original data if RAG fails
      }
    }

    const analysis = await openAI.analyzeFinancials(enhancedFinancialData, userRole, query);
    
    res.json({
      success: true,
      data: analysis
    });
  } catch (error) {
    console.error('Analysis error:', {
      message: error.message,
      stack: error.stack,
      name: error.name,
      code: error.code,
      status: error.status
    });
    
    // Return more specific error messages
    if (error.message.includes('OpenAI API key')) {
      res.status(500).json({ error: 'OpenAI API configuration error. Please check API key.' });
    } else if (error.message.includes('rate limit')) {
      res.status(429).json({ error: 'Rate limit exceeded. Please try again later.' });
    } else if (error.message.includes('authentication failed')) {
      res.status(500).json({ error: 'OpenAI authentication failed. Please check API credentials.' });
    } else {
      res.status(500).json({ error: error.message || 'Analysis failed' });
    }
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