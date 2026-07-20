const http = require('http');
const os = require('os');

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ status: 'ok' }));
  }
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ served_by: os.hostname(), time: new Date().toISOString() }));
});

server.listen(3000, () => console.log(`listening on 3000 (${os.hostname()})`));
