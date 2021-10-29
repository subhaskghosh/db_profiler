const mongoose = require('mongoose');

const tos = new mongoose.Schema({
  "to_column": {
    "type": "String"
  },
  "graph": {
    "type": "String"
  }
});

const froms = new mongoose.Schema({
  "from_column": {
    "type": "String"
  },
  "tos": {
    "type": [
      tos
    ]
  }
});

const scatter_matrices = new mongoose.Schema({
  "_id": {
    "type": "ObjectId"
  },
  "from_column": {
    "type": "String"
  },
  "to_column": {
    "type": "String"
  },
  "graph": {
    "type": "String"
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

module.exports = mongoose.model('scatter_matrices', scatter_matrices);