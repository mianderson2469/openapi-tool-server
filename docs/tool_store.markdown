# Tool Store

The Tool Store is accessible at `http://localhost:3000/store` and lists all available tools, their descriptions, and download counts. Users can download tools from the GitHub repository.

## Available Tools

### time
- **Description**: Returns the current time.
- **URL**: http://localhost:8001
- **Downloads**: 0

### filesystem
- **Description**: Manages local file operations with configurable restrictions.
- **URL**: http://localhost:8002
- **Downloads**: 0

[Add more tools here as they are contributed]

## Downloading Tools
1. Visit the Tool Store at `http://localhost:3000/store`.
2. Click the “Download” button for a tool to record the download.
3. Clone the repository:
   ```bash
   git clone https://github.com/mianderson2469/openapi-tool-server.git
   ```
4. Copy the tool directory from `openapi-servers/servers/<tool_name>` to your local server.
5. Run the setup script to configure the tool:
   ```bash
   cd openapi-tool-server
   ./setup_openapi_tool_server.sh
   ```

## Contributing Tools
See the [Tool Submission Guide](tool_submission.md) to add new tools to the store.