const mongoose = require('mongoose');

const booleaan_type = new mongoose.Schema({
  "n_distinct": {
    "type": "Number"
  },
  "p_distinct": {
    "type": "Number"
  },
  "is_unique": {
    "type": "String"
  },
  "n_unique": {
    "type": "Number"
  },
  "p_unique": {
    "type": "Number"
  },
  "type": {
    "type": "String"
  },
  "hashable": {
    "type": "String"
  },
  "ordering": {
    "type": "String"
  },
  "n_missing": {
    "type": "Number"
  },
  "n": {
    "type": "Number"
  },
  "p_missing": {
    "type": "Number"
  },
  "count": {
    "type": "Number"
  },
  "memory_size": {
    "type": "Number"
  },
  "mode": {
    "type": "String"
  },
  "value_counts_index_sorted": {},
  "column": {
    "type": "String"
  }
});

const boolean_series_descriptions = new mongoose.Schema({
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
  "type": {
    "type": "String"
  },
  "variable": {
    "type": "String"
  },
  "result": {
    "type": booleaan_type
  }
});

module.exports = mongoose.model('boolean_series_descriptions', boolean_series_descriptions);

