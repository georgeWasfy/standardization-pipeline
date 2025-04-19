# ---- Build Stage ----
    FROM node:18-alpine AS builder

    WORKDIR /app
    
    COPY package*.json ./
    RUN npm install
    
    COPY tsconfig.json ./
    COPY src ./src
    
    RUN npm run build
    
    # ---- Production Stage ----
    FROM node:18-alpine
    
    WORKDIR /app
    
    # Copy built files and production deps only
    COPY --from=builder /app/package*.json ./
    RUN npm install --only=production
    
    COPY --from=builder /app/dist ./dist
        
    CMD ["node", "dist/server.js"]
    