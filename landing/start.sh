#!/bin/bash
set -e

# Project Context
APP_NAME="${PWD##*/}"
COMPONENT_NAME=$(basename $(pwd)) # e.g., 'web', 'backend', 'landing'
FULL_SERVICE_NAME="${APP_NAME}-${COMPONENT_NAME}"

# Path to Port Allocator
ALLOCATOR="/home/luis/projects/ops-scripts/port-management/allocate-port.sh"

# Determine Port Type
PORT_TYPE="service"
if [[ "$COMPONENT_NAME" == "web" || "$COMPONENT_NAME" == "landing" ]]; then
    PORT_TYPE="frontend"
elif [[ "$COMPONENT_NAME" == "backend" ]]; then
    PORT_TYPE="backend"
fi

# Allocate/Retrieve Port
echo "[INFO] Requesting port for $FULL_SERVICE_NAME ($PORT_TYPE)..."
if [ -x "$ALLOCATOR" ]; then
    PORT=$($ALLOCATOR "$FULL_SERVICE_NAME" "$PORT_TYPE")
    echo "[SUCCESS] Allocated Port: $PORT"
else
    echo "[ERROR] Port allocator not found at $ALLOCATOR"
    exit 1
fi

# Export for the application
export PORT

# Update/Create .env for Docker
if [ -f ".env" ]; then
    # Update existing PORT if present, or append
    if grep -q "^PORT=" .env; then
        sed -i "s/^PORT=.*/PORT=$PORT/" .env
    else
        echo "PORT=$PORT" >> .env
    fi
else
    echo "PORT=$PORT" > .env
fi

echo "[INFO] Starting application..."
# Detect technology and start
if [ -f "package.json" ]; then
    if [ -f "yarn.lock" ]; then
        yarn install && yarn start
    else
        npm install && npm start
    fi
elif [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    python app.py # Assumption, might need adjustment
elif [ -f "docker-compose.yml" ]; then
    docker-compose up -d --build
else
    echo "[WARN] No standard entry point found. Running custom start..."
    # Fallback or placeholder
fi
