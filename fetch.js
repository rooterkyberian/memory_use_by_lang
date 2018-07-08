const https = require('https');

https.get('https://www.google.com/robots.txt', (resp) => {
  let data = '';

  resp.on('data', (chunk) => {
    data += chunk;
  });

  resp.on('end', () => {
  });

}).on("error", (err) => {
  console.log("Error: " + err.message);
});
