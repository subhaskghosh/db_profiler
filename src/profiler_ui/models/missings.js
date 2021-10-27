const mongoose = require('mongoose');

const missings = new mongoose.Schema({
  "_id": {
    "type": "ObjectId"
  },
  "bar": {
    "name": {
      "type": "String"
    },
    "caption": {
      "type": "String"
    },
    "matrix": {
      "type": "String"
    }
  },
  "matrix": {
    "name": {
      "type": "String"
    },
    "caption": {
      "type": "String"
    },
    "matrix": {
      "type": "String"
    }
  },
  "dendrogram": {
    "name": {
      "type": "String"
    },
    "caption": {
      "type": "String"
    },
    "matrix": {
      "type": "String"
    }
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

module.exports = mongoose.model('missings', missings);