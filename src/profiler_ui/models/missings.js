const mongoose = require('mongoose');

const missings = new mongoose.Schema({
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
  "graph_type": {
      "type": "String"
  },
  "result": {
    "name": {
      "type": "String"
    },
    "caption": {
      "type": "String"
    },
    "matrix": {
      "type": "String"
    }
  }
});

module.exports = mongoose.model('missings', missings);