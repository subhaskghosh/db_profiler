const mongoose = require('mongoose');

const subsample = new mongoose.Schema({
    "id": {"type": "String"},
    "data": { type : Array , "default" : [] },
    "name": {"type": "String"},
    "caption": {"type": "String"}
});

const samples = new mongoose.Schema({
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
  "sample": {
    "type": [
      subsample
    ]
  }
});

module.exports = mongoose.model('samples', samples);