const mongoose = require('mongoose');

const tables = new mongoose.Schema({
  "schema": {
    "type": "String"
  },
  "table": {
    "type": "String"
  },
  "create_date": {
    "type": "Date"
  }
});

module.exports = mongoose.model('tables', tables);