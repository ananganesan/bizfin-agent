const { Pinecone } = require('@pinecone-database/pinecone');
const OpenAI = require('openai');

class VectorService {
  constructor() {
    this.pinecone = new Pinecone({
      apiKey: process.env.PINECONE_API_KEY
    });
    
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    });
    
    this.indexName = process.env.PINECONE_INDEX_NAME || 'bizfin-documents';
    this.index = null;
  }

  async initialize() {
    try {
      // Create index if it doesn't exist
      const existingIndexes = await this.pinecone.listIndexes();
      const indexExists = existingIndexes.indexes?.some(index => index.name === this.indexName);
      
      if (!indexExists) {
        await this.pinecone.createIndex({
          name: this.indexName,
          dimension: 1536, // OpenAI embedding dimension
          metric: 'cosine',
          spec: {
            serverless: {
              cloud: 'aws',
              region: 'us-east-1'
            }
          }
        });
        
        // Wait for index to be ready
        await new Promise(resolve => setTimeout(resolve, 10000));
      }
      
      this.index = this.pinecone.index(this.indexName);
      console.log('Vector service initialized successfully');
    } catch (error) {
      console.error('Failed to initialize vector service:', error);
      throw error;
    }
  }

  // Chunk text into smaller pieces
  chunkText(text, chunkSize = 1000, overlap = 200) {
    const chunks = [];
    const words = text.split(/\s+/);
    
    for (let i = 0; i < words.length; i += chunkSize - overlap) {
      const chunk = words.slice(i, i + chunkSize).join(' ');
      if (chunk.trim()) {
        chunks.push({
          text: chunk,
          startIndex: i,
          endIndex: Math.min(i + chunkSize, words.length)
        });
      }
    }
    
    return chunks;
  }

  // Generate embeddings for text
  async generateEmbedding(text) {
    try {
      const response = await this.openai.embeddings.create({
        model: 'text-embedding-3-small',
        input: text
      });
      
      return response.data[0].embedding;
    } catch (error) {
      console.error('Failed to generate embedding:', error);
      throw error;
    }
  }

  // Store document in vector database
  async storeDocument(documentId, content, metadata = {}) {
    try {
      if (!this.index) {
        await this.initialize();
      }

      const chunks = this.chunkText(content);
      const vectors = [];
      
      for (let i = 0; i < chunks.length; i++) {
        const chunk = chunks[i];
        const embedding = await this.generateEmbedding(chunk.text);
        
        vectors.push({
          id: `${documentId}_chunk_${i}`,
          values: embedding,
          metadata: {
            ...metadata,
            documentId,
            chunkIndex: i,
            text: chunk.text.substring(0, 500), // Store first 500 chars for reference
            fullText: chunk.text,
            startIndex: chunk.startIndex,
            endIndex: chunk.endIndex
          }
        });
      }
      
      // Batch upsert vectors
      const batchSize = 100;
      for (let i = 0; i < vectors.length; i += batchSize) {
        const batch = vectors.slice(i, i + batchSize);
        await this.index.upsert(batch);
      }
      
      return {
        documentId,
        chunksStored: vectors.length,
        metadata
      };
    } catch (error) {
      console.error('Failed to store document:', error);
      throw error;
    }
  }

  // Search for relevant chunks
  async searchRelevantChunks(query, topK = 5, filter = {}) {
    try {
      if (!this.index) {
        await this.initialize();
      }

      const queryEmbedding = await this.generateEmbedding(query);
      
      const results = await this.index.query({
        vector: queryEmbedding,
        topK,
        includeMetadata: true,
        filter
      });
      
      return results.matches.map(match => ({
        score: match.score,
        text: match.metadata.fullText,
        metadata: match.metadata
      }));
    } catch (error) {
      console.error('Failed to search chunks:', error);
      throw error;
    }
  }

  // Delete document from vector database
  async deleteDocument(documentId) {
    try {
      if (!this.index) {
        await this.initialize();
      }

      // Delete all chunks for this document
      await this.index.deleteMany({
        filter: {
          documentId: { $eq: documentId }
        }
      });
      
      return { success: true, documentId };
    } catch (error) {
      console.error('Failed to delete document:', error);
      throw error;
    }
  }
}

module.exports = new VectorService();