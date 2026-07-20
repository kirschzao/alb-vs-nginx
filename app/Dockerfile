FROM node:22-alpine
WORKDIR /app
COPY package.json server.js ./
EXPOSE 3000
HEALTHCHECK --interval=10s --timeout=2s CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "server.js"]
