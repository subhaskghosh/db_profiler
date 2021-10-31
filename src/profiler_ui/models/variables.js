const mongoose = require('mongoose');

const variable_type = new mongoose.Schema({
  "name": {
    "type": "String"
  },
  "type": {
    "type": "String"
  }
});

const variables = new mongoose.Schema({
  "_id": {
    "type": "ObjectId"
  },
  "variables": {
    "type": [
      variable_type
    ]
  },
  "analysis": {
    "schema": {
      "type": "String"
    },
    "table": {
      "type": "String"
    },
    "title": {
      "type": "String"
    },
    "date_start": {
      "type": "Date"
    },
    "date_end": {
      "type": "Date"
    }
  }
});

module.exports = mongoose.model('variables', variables);