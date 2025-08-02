const Anthropic = require('@anthropic-ai/sdk');

class ClaudeAIService {
  constructor() {
    this.client = new Anthropic({
      apiKey: process.env.ANTHROPIC_API_KEY,
    });
  }

  async analyzeFinancials(data, userRole, query) {
    const rolePrompts = {
      'Junior Staff': `You are a basic financial AI assistant. Provide simple explanations of financial metrics and basic insights. Keep responses under 200 words and focus on explaining what the numbers mean.`,
      
      'Intermediate Staff': `You are an intermediate financial AI analyst. Provide contextual analysis, basic strategic recommendations, and 30-60-90 day action plans. Include tool suggestions and scenario analysis. Responses can be 300-500 words.`,
      
      'Departmental Head': `You are an advanced autonomous financial AI advisor. Provide comprehensive strategic analysis, multi-agent collaborative insights, predictive recommendations, and autonomous action plans. Include cross-functional strategies and self-learning insights. Detailed responses welcome.`
    };

    const systemPrompt = rolePrompts[userRole] || rolePrompts['Junior Staff'];
    
    const prompt = `${systemPrompt}

Financial Data Context:
${JSON.stringify(data, null, 2)}

User Query: ${query}

Please provide analysis appropriate for a ${userRole} level user. Include specific insights, recommendations, and actionable next steps based on the role's capabilities.`;

    try {
      const response = await this.client.messages.create({
        model: 'claude-3-sonnet-20240229',
        max_tokens: 2000,
        temperature: 0.7,
        messages: [{
          role: 'user',
          content: prompt
        }]
      });

      return {
        content: response.content[0].text,
        role: userRole,
        insights: this.extractInsights(response.content[0].text),
        tools: this.suggestTools(userRole),
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Claude AI Error:', error);
      throw new Error('AI analysis failed');
    }
  }

  extractInsights(content) {
    const insights = [];
    const lines = content.split('\n');
    
    lines.forEach(line => {
      if (line.includes('insight:') || line.includes('key point:') || line.includes('important:')) {
        insights.push(line.replace(/.*?insight:|.*?key point:|.*?important:/i, '').trim());
      }
    });
    
    return insights.length > 0 ? insights : ['Analysis completed successfully'];
  }

  suggestTools(userRole) {
    const toolsByRole = {
      'Junior Staff': ['Basic Calculator', 'Ratio Explainer'],
      'Intermediate Staff': ['Cash Flow Simulator', 'Ratio Analysis', 'Benchmarking Tool', 'Scenario Planner'],
      'Departmental Head': ['Multi-Agent Orchestration', 'Predictive Analytics', 'Autonomous Planning', 'Strategic Optimizer']
    };
    
    return toolsByRole[userRole] || [];
  }

  async generateReport(financialData, userRole) {
    const prompt = `Generate a comprehensive financial analysis report for a ${userRole} level user based on this data:

${JSON.stringify(financialData, null, 2)}

Include:
1. Executive Summary
2. Key Performance Indicators
3. Department-wise Analysis (Sales, Finance, Production, Materials)
4. Strategic Recommendations
5. Risk Assessment

Format as a professional financial report.`;

    try {
      const response = await this.client.messages.create({
        model: 'claude-3-sonnet-20240229',
        max_tokens: 4000,
        temperature: 0.5,
        messages: [{
          role: 'user',
          content: prompt
        }]
      });

      return response.content[0].text;
    } catch (error) {
      console.error('Report generation error:', error);
      throw new Error('Report generation failed');
    }
  }
}

module.exports = new ClaudeAIService();