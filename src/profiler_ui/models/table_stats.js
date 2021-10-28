const mongoose = require('mongoose');

const table_stats = new mongoose.Schema({
  "_id": {
    "type": "ObjectId"
  },
  "n": {
    "type": "Number"
  },
  "n_var": {
    "type": "Number"
  },
  "memory_size": {
    "type": "Number"
  },
  "record_size": {
    "type": "Number"
  },
  "n_cells_missing": {
    "type": "Number"
  },
  "n_vars_with_missing": {
    "type": "Number"
  },
  "n_vars_all_missing": {
    "type": "Number"
  },
  "p_cells_missing": {
    "type": "Number"
  },
  "types": { type : Array , "default" : [] },
  "n_duplicates": {
    "type": "Number"
  },
  "p_duplicates": {
    "type": "Number"
  },
  "correlation_plot": {
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

module.exports = mongoose.model('table_stats', table_stats);