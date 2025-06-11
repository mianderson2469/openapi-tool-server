# Tool Submission Guide

This guide explains how to create and submit a new tool to the OpenAPI Tool Server.

## Creating a Tool
1. **Structure**:
   - Create a directory in `openapi-servers/servers/<tool_name>/`.
   - Add:
     - `main.py`: A FastAPI app exposing OpenAPI endpoints.
     - `requirements.txt`: List of Python dependencies.
   - Example (`time` tool):
     ```python
     from fastapi import FastAPI
     from datetime import datetime

     app = FastAPI()

     @app.get("/time")
     async def get_time():
         return {"current_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
     ```

2. **Dependencies**:
   - Include `fastapi` and `uvicorn` in `requirements.txt` if not specified.
   - Example:
     ```
     fastapi
     uvicorn
     ```

3. **Testing**:
   - Run locally:
     ```bash
     cd openapi-servers/servers/<tool_name>
     python3 -m venv venv
     source venv/bin/activate
     pip install -r requirements.txt
     uvicorn main:app --host 0.0.0.0 --port 8001
     ```
   - Test with OpenWebUI by adding the tool URL (e.g., `http://localhost:8001`).

## Submitting a Tool
1. **Fork the Repository**:
   ```bash
   git clone https://github.com/<your_username>/openapi-tool-server.git
   cd openapi-tool-server
   ```

2. **Add Your Tool**:
   - Place your tool in `openapi-servers/servers/<tool_name>/`.
   - Update `docs/tool_store.md` with:
     ```markdown
     ### <tool_name>
     - **Description**: [What the tool does]
     - **URL**: http://localhost:<port>
     - **Downloads**: 0
     ```

3. **Commit and Push**:
   ```bash
   git add .
   git commit -m "Add <tool_name> tool"
   git push origin main
   ```

4. **Create a Pull Request**:
   - Go to `https://github.com/mianderson2469/openapi-tool-server`.
   - Create a pull request from your fork.
   - Follow the [pull request template](.github/PULL_REQUEST_TEMPLATE.md).

## Guidelines
- Ensure your tool follows the OpenAPI specification.
- Test thoroughly with OpenWebUI.
- Provide a clear description in `docs/tool_store.md`.
- Avoid dependency conflicts by specifying exact versions in `requirements.txt`.

## Example Pull Request
See [example PR](#) for a sample tool submission.