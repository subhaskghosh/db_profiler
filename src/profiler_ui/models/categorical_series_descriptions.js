const mongoose = require('mongoose');

const categorical_type = new mongoose.Schema({
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
  "first_rows": {
    "0": {
      "type": "String"
    },
    "1": {
      "type": "String"
    },
    "2": {
      "type": "String"
    },
    "3": {
      "type": "String"
    },
    "4": {
      "type": "String"
    }
  },
  "chi_squared": {
    "statistic": {
      "type": "Number"
    },
    "pvalue": {
      "type": "Number"
    }
  },
  "max_length": {
    "type": "Number"
  },
  "mean_length": {
    "type": "Number"
  },
  "median_length": {
    "type": "Number"
  },
  "min_length": {
    "type": "Number"
  },
  "length_histogram": {
    "18": {
      "type": "Number"
    }
  },
  "histogram_length": {
    "counts": {
      "type": [
        "Number"
      ]
    },
    "bin_edges": {
      "type": [
        "Number"
      ]
    }
  },
  "histogram_graph": {
    "type": "String"
  },
  "n_characters_distinct": {
    "type": "Number"
  },
  "n_characters": {
    "type": "Number"
  },
  "n_block_alias": {
    "type": "Number"
  },
  "n_scripts": {
    "type": "Number"
  },
  "n_category": {
    "type": "Number"
  },
  "word_counts_graph": {
    "type": "String"
  },
  "column": {
    "type": "String"
  }
});

const categorical_series_descriptions = new mongoose.Schema({
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
    "type": categorical_type
  }
});

module.exports = mongoose.model('categorical_series_descriptions', categorical_series_descriptions);

