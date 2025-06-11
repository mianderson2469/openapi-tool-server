from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import uvicorn
import json
import os

app = FastAPI()

# Enable CORS for web interface
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Storage for tools
TOOLS_FILE = "tools.json"
if not os.path.exists(TOOLS_FILE):
    with open(TOOLS_FILE, "w") as f:
        json.dump({"tools": []}, f)

class Tool(BaseModel):
    name: str
    url: str
    description: str = ""
    downloads: int = 0

# Load tools from file
def load_tools():
    with open(TOOLS_FILE, "r") as f:
        return json.load(f)["tools"]

# Save tools to file
def save_tools(tools):
    with open(TOOLS_FILE, "w") as f:
        json.dump({"tools": tools}, f)

# Get all tools
@app.get("/tools", response_model=List[Tool])
async def get_tools():
    return load_tools()

# Add a new tool
@app.post("/tools", response_model=Tool)
async def add_tool(tool: Tool):
    tools = load_tools()
    if any(t["name"] == tool.name for t in tools):
        raise HTTPException(status_code=400, detail="Tool name already exists")
    tools.append({"name": tool.name, "url": tool.url, "description": tool.description, "downloads": 0})
    save_tools(tools)
    return tool

# Delete a tool
@app.delete("/tools/{name}")
async def delete_tool(name: str):
    tools = load_tools()
    if not any(t["name"] == name for t in tools):
        raise HTTPException(status_code=404, detail="Tool not found")
    tools = [t for t in tools if t["name"] != name]
    save_tools(tools)
    return {"message": "Tool deleted"}

# Increment download count
@app.post("/tools/{name}/download")
async def increment_download(name: str):
    tools = load_tools()
    for tool in tools:
        if tool["name"] == name:
            tool["downloads"] += 1
            save_tools(tools)
            return {"message": f"Download count for {name} incremented"}
    raise HTTPException(status_code=404, detail="Tool not found")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)