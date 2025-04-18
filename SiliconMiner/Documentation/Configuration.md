# Configuration Files for Different Environments

The SiliconMiner application supports different environments, such as development, production, and testing. Each environment has its own configuration file that specifies the settings and parameters for that environment.

## Configuration Files

### Development Configuration

The development configuration file (`config.development.json`) contains settings for the development environment. It includes parameters such as the API endpoint, logging level, and other development-specific settings.

Example `config.development.json`:
```json
{
    "environment": "development",
    "apiEndpoint": "https://dev.api.siliconminer.com",
    "loggingLevel": "debug"
}
```

### Production Configuration

The production configuration file (`config.production.json`) contains settings for the production environment. It includes parameters such as the API endpoint, logging level, and other production-specific settings.

Example `config.production.json`:
```json
{
    "environment": "production",
    "apiEndpoint": "https://api.siliconminer.com",
    "loggingLevel": "error"
}
```

### Testing Configuration

The testing configuration file (`config.testing.json`) contains settings for the testing environment. It includes parameters such as the API endpoint, logging level, and other testing-specific settings.

Example `config.testing.json`:
```json
{
    "environment": "testing",
    "apiEndpoint": "https://test.api.siliconminer.com",
    "loggingLevel": "info"
}
```

## Environment Setup

To set up the environment for the SiliconMiner application, follow these steps:

1. **Create Configuration Files**: Create separate configuration files for each environment (e.g., `config.development.json`, `config.production.json`, `config.testing.json`).

2. **Specify Environment Variables**: Set the environment variables to specify the desired environment. For example:
   ```
   export ENVIRONMENT=development
   ```

3. **Load Configuration**: Modify the application code to load the appropriate configuration file based on the environment variable.

4. **Run the Application**: Run the SiliconMiner application with the desired environment settings.
