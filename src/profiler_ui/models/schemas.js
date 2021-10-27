const mongoose = require('mongoose');

const schemas = new mongoose.Schema({
  "schema": {
    "type": "String"
  },
  "create_date": {
    "type": "Date"
  }
});

module.exports = mongoose.model('schemas', schemas);