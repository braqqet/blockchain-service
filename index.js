const express = require('express');
const app = express();

const PORT = process.env.PORT;

// add middleware
app.use(express.json());

// import routes

const tokenization_route = require('./routes/tokenization_route');

app.use('/api/v1', tokenization_route);

// start listening to port
app.listen(PORT, () => {
  console.log('listening to port 8080');
});