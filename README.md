# Business Finance Advisory Agent

A role-based AI financial advisor powered by OpenAI GPT-4 that provides intelligent financial analysis and recommendations based on user roles (Junior Staff, Intermediate Staff, Departmental Head).

## Features

- **Role-Based Access Control**: Different capabilities based on user role
- **File Upload Support**: Upload Excel, CSV, and PDF financial documents
- **AI-Powered Analysis**: OpenAI GPT-4 provides contextual financial insights
- **Interactive Chat Interface**: Ask questions about your financial data
- **Report Generation**: Generate comprehensive financial reports
- **Real-time Analysis**: Instant responses and recommendations

## User Roles

### Junior Staff
- Basic financial explanations
- Department-specific analysis
- Simple insights and metrics

### Intermediate Staff
- Context-aware responses
- Basic action plans
- Scenario simulation
- Strategic recommendations

### Departmental Head
- Advanced autonomous insights
- Strategic planning
- Cross-functional analysis
- Predictive analytics

## Installation

1. Install dependencies:
```bash
npm run install-deps
```

2. Set up environment variables:
   - Copy `backend/.env.example` to `backend/.env`
   - Add your OpenAI API key to `OPENAI_API_KEY`
   - Configure other settings as needed

3. Start the application:
```bash
# Development mode (both backend and frontend)
npm run dev

# Or start individually
npm run start-backend
npm run start-frontend
```

## Demo Users

- **Junior Staff**: `junior_user` / `junior123`
- **Intermediate Staff**: `intermediate_user` / `junior123`
- **Department Head**: `department_head` / `junior123`

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user

### File Upload
- `POST /api/upload/financial-data` - Upload financial documents

### Analysis
- `POST /api/analysis/query` - Ask questions about financial data
- `POST /api/analysis/report` - Generate comprehensive reports
- `GET /api/analysis/capabilities/:role` - Get role capabilities

## Technologies Used

- **Backend**: Node.js, Express, OpenAI GPT-4
- **Frontend**: Vanilla JavaScript, HTML5, CSS3
- **File Processing**: XLSX library for Excel files
- **Authentication**: JWT tokens
- **Database**: In-memory (demo), easily extendable to PostgreSQL/MongoDB

## Deployment

The application is ready for deployment on any Node.js hosting platform. For production:

1. Set `NODE_ENV=production`
2. Configure proper database
3. Set up HTTPS
4. Configure proper CORS origins
5. Set strong JWT secrets

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License