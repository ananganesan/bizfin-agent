const OpenAI = require('openai');
const loggingService = require('./logging-service');

class OpenAIService {
  constructor() {
    this.client = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
  }

  async analyzeFinancials(data, userRole, query) {
    const rolePrompts = {
      'Junior Staff': `You are a basic financial AI assistant. Provide simple explanations of financial metrics and basic insights. Keep responses under 200 words and focus on explaining what the numbers mean.`,
      
      'Intermediate Staff': `You are an intermediate financial AI analyst. Provide contextual analysis, basic strategic recommendations, and 30-60-90 day action plans. Include tool suggestions and scenario analysis. Responses can be 300-500 words.`,
      
      'Departmental Head': `You are an advanced autonomous financial AI advisor. Provide comprehensive strategic analysis, multi-agent collaborative insights, predictive recommendations, and autonomous action plans. Include cross-functional strategies and self-learning insights. Detailed responses welcome.`
    };

    const systemPrompt = rolePrompts[userRole] || rolePrompts['Junior Staff'];
    
    // Handle different data formats
    let dataContent = '';
    let ragContext = '';
    
    // Check if we have RAG-enhanced data
    if (data && data.relevantContext) {
      // Extract the most relevant context from RAG
      ragContext = '\n\nRelevant Context from Document:\n';
      data.relevantContext.forEach((chunk, index) => {
        ragContext += `\n[Context ${index + 1} - Relevance Score: ${chunk.score.toFixed(3)}]\n${chunk.text}\n`;
      });
      
      // Remove relevantContext from data to avoid duplication
      const { relevantContext, ...remainingData } = data;
      data = remainingData;
    }
    
    if (data && data.type === 'pdf') {
      // For PDF content, use the extracted text directly
      dataContent = `Document Type: PDF (${data.pages} pages)\nContent:\n${data.content}`;
    } else if (data) {
      // For structured data (Excel/CSV), stringify it
      dataContent = JSON.stringify(data, null, 2);
    } else {
      dataContent = 'No financial data provided';
    }
    
    // Combine main data with RAG context
    dataContent += ragContext;

    const userPrompt = `${systemPrompt}

Financial Data Context:
${dataContent}

User Query: ${query}

Please provide analysis appropriate for a ${userRole} level user. Include specific insights, recommendations, and actionable next steps based on the role's capabilities.`;

    try {
      // Log the request
      loggingService.logOpenAI('request', {
        model: 'gpt-4o-mini',
        userRole,
        query,
        dataLength: dataContent.length,
        hasRagContext: !!ragContext,
        systemPromptLength: systemPrompt.length
      });

      const startTime = Date.now();
      const response = await this.client.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: systemPrompt
          },
          {
            role: 'user',
            content: `Financial Data: ${dataContent}\n\nQuery: ${query}`
          }
        ],
        temperature: 0.7,
        max_tokens: 2000
      });

      const content = response.choices[0].message.content;
      
      // Log the response
      loggingService.logOpenAI('response', {
        responseTime: Date.now() - startTime,
        tokensUsed: response.usage?.total_tokens || 0,
        promptTokens: response.usage?.prompt_tokens || 0,
        completionTokens: response.usage?.completion_tokens || 0,
        contentLength: content.length,
        model: response.model
      });

      return {
        content: content,
        role: userRole,
        insights: this.extractInsights(content),
        tools: this.suggestTools(userRole),
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('OpenAI Error:', error);
      if (error.code === 'invalid_api_key') {
        throw new Error('OpenAI API key is invalid or missing');
      } else if (error.status === 401) {
        throw new Error('OpenAI API authentication failed');
      } else if (error.status === 429) {
        throw new Error('OpenAI API rate limit exceeded');
      }
      throw new Error(`AI analysis failed: ${error.message}`);
    }
  }

  extractInsights(content) {
    const insights = [];
    const lines = content.split('\n');
    
    lines.forEach(line => {
      if (line.includes('insight:') || line.includes('key point:') || line.includes('important:') || line.includes('•') || line.includes('-')) {
        const cleanedLine = line.replace(/.*?insight:|.*?key point:|.*?important:|•|-/i, '').trim();
        if (cleanedLine.length > 10) {
          insights.push(cleanedLine);
        }
      }
    });
    
    return insights.length > 0 ? insights.slice(0, 5) : ['Analysis completed successfully'];
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
      const response = await this.client.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: 'You are a professional financial analyst creating detailed reports.'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        temperature: 0.5,
        max_tokens: 4000
      });

      return response.choices[0].message.content;
    } catch (error) {
      console.error('Report generation error:', error);
      if (error.code === 'invalid_api_key') {
        throw new Error('OpenAI API key is invalid or missing');
      } else if (error.status === 401) {
        throw new Error('OpenAI API authentication failed');
      }
      throw new Error(`Report generation failed: ${error.message}`);
    }
  }
}

module.exports = new OpenAIService();