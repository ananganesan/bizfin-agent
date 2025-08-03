const express = require('express');
const router = express.Router();
const multer = require('multer');
const xlsx = require('xlsx');
const path = require('path');
const fs = require('fs');
const pdfParse = require('pdf-parse');
const vectorService = require('../services/vector-service');

const storage = multer.diskStorage({
  destination: './uploads',
  filename: (req, file, cb) => {
    cb(null, Date.now() + '-' + file.originalname);
  }
});

const upload = multer({ 
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /xlsx|xls|csv|pdf/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    
    if (extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only Excel, CSV, and PDF files are allowed'));
    }
  }
});

router.post('/financial-data', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const filePath = req.file.path;
    const fileExtension = path.extname(req.file.originalname).toLowerCase();
    
    let financialData = {};
    
    if (fileExtension === '.xlsx' || fileExtension === '.xls' || fileExtension === '.csv') {
      const workbook = xlsx.readFile(filePath);
      const sheetName = workbook.SheetNames[0];
      const worksheet = workbook.Sheets[sheetName];
      financialData = xlsx.utils.sheet_to_json(worksheet);
    } else if (fileExtension === '.pdf') {
      // Extract text content from PDF
      const dataBuffer = fs.readFileSync(filePath);
      const pdfData = await pdfParse(dataBuffer);
      
      // Store PDF content as structured data
      financialData = {
        type: 'pdf',
        content: pdfData.text,
        pages: pdfData.numpages,
        info: pdfData.info
      };
    }
    
    // Store in vector database for RAG
    try {
      let contentToStore = '';
      let documentType = 'financial';
      
      if (fileExtension === '.pdf') {
        contentToStore = financialData.content;
        documentType = 'pdf';
      } else {
        // For Excel/CSV, convert to readable text format
        contentToStore = JSON.stringify(financialData, null, 2);
        documentType = 'spreadsheet';
      }
      
      if (contentToStore) {
        const documentId = `${Date.now()}_${req.file.originalname}`;
        await vectorService.storeDocument(documentId, contentToStore, {
          filename: req.file.originalname,
          uploadedAt: new Date().toISOString(),
          fileType: fileExtension,
          documentType: documentType
        });
        
        // Add document ID to the response
        financialData.vectorDocumentId = documentId;
      }
    } catch (vectorError) {
      console.error('Vector storage error:', vectorError);
      // Continue without vector storage - don't fail the upload
    }
    
    // Clean up uploaded file
    fs.unlinkSync(filePath);
    
    res.json({
      success: true,
      data: {
        filename: req.file.originalname,
        financialData,
        processedAt: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('File processing error:', error);
    res.status(500).json({ error: 'File processing failed' });
  }
});

module.exports = router;