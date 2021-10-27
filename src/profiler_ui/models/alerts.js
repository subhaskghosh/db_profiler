const mongoose = require('mongoose');

const alerts = new mongoose.Schema({
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
  "alerts": {
    "type": [
      "String"
    ]
  }
});

module.exports = mongoose.model('alerts', alerts);