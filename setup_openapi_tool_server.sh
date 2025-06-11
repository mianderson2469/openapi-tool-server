#!/bin/bash

# Exit on any error
set -e

# Define directories and repository URLs
REPO_DIR="$HOME/openapi-tool-server"
OPENAPI_SERVERS_DIR="$REPO_DIR/openapi-servers"
WEB_INTERFACE_DIR="$REPO_DIR/web-interface"
OPENAPI_SERVERS_REPO="https://github.com/mianderson2469/openapi-tool-server.git"
WEB_INTERFACE_PORT=3000
CENTRAL_SERVER_PORT=8000
INITIAL_TOOL_PORT=8001

echo "Starting OpenAPI Tool Server and Web Interface Setup..."

# Function to check and kill processes on a port
check_port() {
    local port=$1
    if sudo netstat -tulnp | grep ":$port" > /dev/null; then
        echo "Port $port is in use. Killing process..."
        sudo fuser -k "$port"/tcp || true
    fi
}

# Check required ports
check_port $CENTRAL_SERVER_PORT
check_port $WEB_INTERFACE_PORT
for ((port=$INITIAL_TOOL_PORT; port<$INITIAL_TOOL_PORT+10; port++)); do
    check_port $port
done

# Install system dependencies
echo "Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv git curl

# Fix any broken packages
sudo apt-get install -f
sudo dpkg --configure -a
sudo apt-get clean

# Install nvm and Node.js
echo "Installing nvm and Node.js 18..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
if ! nvm --version > /dev/null 2>&1; then
    echo "Failed to install nvm. Please check your network and try again."
    exit 1
fi
nvm install 18
nvm use 18
npm install -g npm
node --version || { echo "Node.js installation failed."; exit 1; }
npm --version || { echo "npm installation failed."; exit 1; }

# Install uv for Python environment management
echo "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# Clone repository
echo "Cloning openapi-tool-server repository..."
if [ -d "$REPO_DIR" ]; then
    echo "Directory $REPO_DIR already exists. Pulling latest changes..."
    cd "$REPO_DIR"
    git pull
else
    git clone "$OPENAPI_SERVERS_REPO" "$REPO_DIR"
    cd "$REPO_DIR"
fi

# Set up virtual environment for centralized OpenAPI Tool Server
echo "Setting up centralized OpenAPI Tool Server..."
cd "$OPENAPI_SERVERS_DIR"
python3 -m venv venv
source venv/bin/activate
pip install fastapi uvicorn pydantic
deactivate

# Start centralized server in the background
echo "Starting centralized OpenAPI Tool Server on port $CENTRAL_SERVER_PORT..."
source venv/bin/activate
nohup uvicorn main:app --host 0.0.0.0 --port "$CENTRAL_SERVER_PORT" --reload > central_server.log 2>&1 &
deactivate
echo "Centralized server started. Logs are in $OPENAPI_SERVERS_DIR/central_server.log"

# Set up virtual environments for all tools
echo "Setting up virtual environments for all tools..."
cd "$OPENAPI_SERVERS_DIR/servers"
port=$INITIAL_TOOL_PORT
for tool_dir in */; do
    if [ -d "$tool_dir" ]; then
        tool_name=$(basename "$tool_dir")
        echo "Setting up $tool_name tool..."
        cd "$tool_dir"
        python3 -m venv venv
        source venv/bin/activate
        if [ -f "requirements.txt" ]; then
            pip install -r requirements.txt
        else
            pip install fastapi uvicorn
        fi
        # Start tool server in the background
        echo "Starting $tool_name server on port $port..."
        nohup uvicorn main:app --host 0.0.0.0 --port "$port" --reload > server.log 2>&1 &
        echo "$tool_name server started. Logs are in $OPENAPI_SERVERS_DIR/servers/$tool_name/server.log"
        deactivate
        # Register tool with centralized server
        sleep 2
        curl -X POST "http://localhost:$CENTRAL_SERVER_PORT/tools" -H "Content-Type: application/json" -d "{\"name\":\"$tool_name\",\"url\":\"http://localhost:$port\"}" || echo "Failed to register $tool_name. Check central_server.log."
        port=$((port + 1))
        cd "$OPENAPI_SERVERS_DIR/servers"
    fi
done

# Set up web interface
echo "Setting up web interface..."
cd "$WEB_INTERFACE_DIR"
if [ -d ".git" ]; then
    echo "Directory $WEB_INTERFACE_DIR already exists. Pulling latest changes..."
    git pull || true
else
    npx create-react-app . || { echo "Failed to create React app. Check npm logs."; exit 1; }
fi

# Install Tailwind CSS and dependencies
echo "Installing Tailwind CSS and axios..."
npm install -D tailwindcss
npm install axios
echo "Initializing Tailwind CSS..."
./node_modules/.bin/tailwindcss init || npx tailwindcss init || { echo "Failed to initialize Tailwind CSS."; exit 1; }

# Fix npm vulnerabilities
echo "Fixing npm vulnerabilities..."
npm audit fix || echo "Some vulnerabilities require manual intervention. Run 'npm audit' for details."

# Start React app in the background
echo "Starting React web interface on port $WEB_INTERFACE_PORT..."
npm install
nohup npm start > react.log 2>&1 &
echo "Web interface started. Logs are in $WEB_INTERFACE_DIR/react.log"

echo "Setup complete!"
echo "Access the web interface at http://localhost:$WEB_INTERFACE_PORT"
echo "Centralized OpenAPI Tool Server is running at http://localhost:$CENTRAL_SERVER_PORT"
echo "Add the centralized server to OpenWebUI at http://localhost:$CENTRAL_SERVER_PORT"
echo "Individual tool servers are running on ports $INITIAL_TOOL_PORT and above"
echo "To add tools to OpenWebUI, go to Settings > Tools and enter the tool URLs (e.g., http://localhost:8001 for time)."
echo "Check logs for errors:"
echo "  Centralized server: $OPENAPI_SERVERS_DIR/central_server.log"
echo "  Tool servers: $OPENAPI_SERVERS_DIR/servers/<tool>/server.log"
echo "  Web interface: $WEB_INTERFACE_DIR/react.log"