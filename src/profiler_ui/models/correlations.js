const mongoose = require('mongoose');

const correlations = new mongoose.Schema({
  "_id": {
    "type": "ObjectId"
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
  },
  "algorithm": {
    "type": "String"
  },
  "matrix": {
    "type": "String"
  },
  "description": {
    "type": "String"
  }
});

module.exports = mongoose.model('correlations', correlations);