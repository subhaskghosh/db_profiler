require('dotenv').config();
const mongoose = require('mongoose');

mongoose.connect(process.env.DATABASE, {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

mongoose.connection
  .on('open', () => {
    console.log('Mongoose connection open');
  })
  .on('error', (err) => {
    console.log(`Connection error: ${err.message}`);
  });

require('./models/schemas');
require('./models/tables');
require('./models/variables');
require('./models/alerts');
require('./models/samples');
require('./models/table_stats');
require('./models/numeric_series_descriptions');
require('./models/categorical_series_descriptions');
require('./models/boolean_series_descriptions');
require('./models/unsupported_series_descriptions');
require('./models/missings');
require('./models/correlations');
require('./models/scatter_matrices');

const app = require('./app');

const server = app.listen(3000, () => {
  console.log(`Express is running on port ${server.address().port}`);
});