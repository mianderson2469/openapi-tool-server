# OpenAPI Tool Server

An OpenAPI Tool Server for OpenWebUI, featuring a web interface for managing tools and a community tool store. Users can deploy their own server, add tools from the store, and contribute new tools via GitHub pull requests.

## Features
- **Centralized Server**: Manages multiple OpenAPI-compatible tools, running at `http://localhost:8000`.
- **Tool Servers**: Individual tools (e.g., `time`, `filesystem`) run on ports 8001+ with isolated virtual environments.
- **Web Interface**: A React-based UI for adding, deleting, and browsing tools, accessible at `http://localhost:3000`.
- **Tool Store**: Displays available tools, descriptions, and download counts, with links to GitHub for downloads.
- **Community Contributions**: Submit new tools via pull requests to the `openapi-servers/servers/` directory.

## Prerequisites
- Ubuntu 24.04
- OpenWebUI (v0.6 or later) and Ollama installed
- Internet connection for dependency installation

## Quick Start
1. Clone the repository:
   ```bash
   git clone https://github.com/mianderson2469/openapi-tool-server.git
   cd openapi-tool-server
   ```
2. Run the setup script:
   ```bash
   chmod +x setup_openapi_tool_server.sh
   ./setup_openapi_tool_server.sh
   ```
3. Access the web interface at `http://localhost:3000`.
4. Add the centralized server to OpenWebUI:
   - Go to OpenWebUI > Settings > Tools.
   - Add `http://localhost:8000` or individual tool URLs (e.g., `http://localhost:8001`).

## Documentation
- [Setup Guide](docs/setup.md)
- [Tool Submission Guide](docs/tool_submission.md)
- [Tool Store Guide](docs/tool_store.md)

## Contributing
We welcome contributions! To submit a new tool:
1. Fork the repository.
2. Add your tool to `openapi-servers/servers/<tool_name>/` with `main.py` and `requirements.txt`.
3. Update `docs/tool_store.md` with your tool’s description.
4. Submit a pull request following the [template](.github/PULL_REQUEST_TEMPLATE.md).

## License
MIT License. See [LICENSE](LICENSE) for details.

## Support
For issues, open a ticket on GitHub or check logs:
- Centralized server: `openapi-servers/central_server.log`
- Tool servers: `openapi-servers/servers/<tool>/server.log`
- Web interface: `web-interface/react.log`