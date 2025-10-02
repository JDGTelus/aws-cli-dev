# Port Mapping Guide

## Overview

The container exposes common development ports, allowing you to run web applications inside the container and access them from your host browser.

## Exposed Ports

### Frontend Development

| Port | Framework/Tool | Usage |
|------|---------------|-------|
| 3000 | React, Next.js | Default dev server |
| 3001 | Alternative | Secondary frontend app |
| 5173 | Vite | Default Vite dev server |
| 8080 | Vue.js | Default Vue dev server |
| 4200 | Angular | Default Angular dev server |

### Backend Development

| Port | Framework | Usage |
|------|-----------|-------|
| 5000 | Flask | Default Flask dev server |
| 8000 | Django, FastAPI | Default server |
| 8001 | Alternative | Secondary backend |
| 9000 | Alternative | Additional backend |

### Node.js Services

| Port | Service | Usage |
|------|---------|-------|
| 3030 | Express | Alternative Express port |
| 4000 | GraphQL/Apollo | Default GraphQL server |
| 5001 | API | Alternative API port |

### Databases

| Port | Database | Usage |
|------|----------|-------|
| 5432 | PostgreSQL | Default PostgreSQL |
| 3306 | MySQL | Default MySQL |
| 27017 | MongoDB | Default MongoDB |
| 6379 | Redis | Default Redis |

## Usage Examples

### React Application

```bash
# Inside container
cd workspace/my-react-app
npm create vite@latest . -- --template react
npm install
npm run dev

# Access from host browser
# http://localhost:5173
```

### Flask API

```bash
# Inside container
cd workspace/my-api
cat > app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return {'message': 'Hello from container!'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

python app.py

# Access from host browser
# http://localhost:5000
```

### Next.js Application

```bash
# Inside container
cd workspace/my-nextjs-app
npx create-next-app@latest .
npm run dev

# Access from host browser
# http://localhost:3000
```

### FastAPI Backend

```bash
# Inside container
cd workspace/my-fastapi
cat > main.py << 'EOF'
from fastapi import FastAPI
import uvicorn

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI!"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

python main.py

# Access from host browser
# http://localhost:8000
```

### Express API

```bash
# Inside container
cd workspace/my-express-api
npm init -y
npm install express
cat > index.js << 'EOF'
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.json({ message: 'Hello from Express!' });
});

app.listen(3030, '0.0.0.0', () => {
  console.log('Server running on port 3030');
});
EOF

node index.js

# Access from host browser
# http://localhost:3030
```

## Important Notes

### Binding to 0.0.0.0

When starting servers inside the container, **always bind to `0.0.0.0`**, not `localhost` or `127.0.0.1`:

✅ **Correct:**
```python
app.run(host='0.0.0.0', port=5000)
```

❌ **Wrong:**
```python
app.run(host='localhost', port=5000)  # Won't be accessible from host!
```

### Checking Port Usage

```bash
# Inside container - check what's listening
netstat -tlnp

# Or using lsof (if installed)
lsof -i :3000
```

### Multiple Applications

You can run multiple apps simultaneously on different ports:

```bash
# Terminal 1 - React frontend
cd workspace/frontend && npm run dev  # Port 3000

# Terminal 2 - Flask backend
cd workspace/backend && python app.py  # Port 5000

# Access:
# Frontend: http://localhost:3000
# Backend API: http://localhost:5000
```

## Troubleshooting

### Port Already in Use

If you see "port already in use":

```bash
# Inside container - find what's using the port
lsof -i :3000

# Kill the process
kill -9 <PID>
```

### Can't Access from Host

1. **Check binding**: Server must bind to `0.0.0.0`
2. **Check port**: Ensure the port is in the exposed list
3. **Check firewall**: Ensure host firewall allows the port
4. **Restart container**: After changing docker-compose.yml

```bash
docker-compose down
docker-compose up -d
```

### Adding More Ports

Edit `docker-compose.yml`:

```yaml
ports:
  - "3000:3000"
  - "YOUR_PORT:YOUR_PORT"  # Add your port
```

Then restart:
```bash
docker-compose down
docker-compose up -d
```

## Common Scenarios

### Full-Stack Development

```bash
# Frontend (React on 3000)
cd workspace/frontend
npm run dev

# Backend (FastAPI on 8000)
cd workspace/backend
uvicorn main:app --host 0.0.0.0 --port 8000

# Database (PostgreSQL on 5432)
# Already available if PostgreSQL is installed

# Access:
# Frontend: http://localhost:3000
# Backend: http://localhost:8000
# Database: localhost:5432
```

### Microservices

```bash
# Service 1 - User API (port 5000)
cd workspace/user-service && flask run --host=0.0.0.0 --port=5000

# Service 2 - Product API (port 5001)
cd workspace/product-service && flask run --host=0.0.0.0 --port=5001

# Service 3 - Order API (port 8000)
cd workspace/order-service && uvicorn main:app --host 0.0.0.0 --port 8000

# API Gateway (port 4000)
cd workspace/gateway && node index.js
```

## Best Practices

1. **Document your ports** - Keep track of which service uses which port
2. **Use environment variables** - Don't hardcode ports
3. **Consistent binding** - Always use `0.0.0.0` for containerized apps
4. **Check conflicts** - Ensure ports don't conflict with host services
5. **Clean shutdown** - Stop servers properly to free ports

## Summary

- All common dev ports are pre-mapped
- Bind servers to `0.0.0.0` (not localhost)
- Access from host via `http://localhost:PORT`
- Multiple apps can run simultaneously on different ports
- Add custom ports in `docker-compose.yml` if needed
