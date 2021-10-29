const mongoose = require('mongoose');

const numeric_type = new mongoose.Schema({
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
  "value_counts_without_nan": {},
  "value_counts_index_sorted": {},
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
  "n_negative": {
    "type": "Number"
  },
  "p_negative": {
    "type": "Number"
  },
  "n_infinite": {
    "type": "Number"
  },
  "n_zeros": {
    "type": "Number"
  },
  "mean": {
    "type": "Number"
  },
  "std": {
    "type": "Number"
  },
  "variance": {
    "type": "Number"
  },
  "min": {
    "type": "Number"
  },
  "max": {
    "type": "Number"
  },
  "kurtosis": {
    "type": "Number"
  },
  "skewness": {
    "type": "Number"
  },
  "sum": {
    "type": "Number"
  },
  "mad": {
    "type": "Number"
  },
  "chi_squared": {
    "statistic": {
      "type": "Number"
    },
    "pvalue": {
      "type": "Number"
    }
  },
  "range": {
    "type": "Number"
  },
  "5%": {
    "type": "Number"
  },
  "25%": {
    "type": "Number"
  },
  "50%": {
    "type": "Number"
  },
  "75%": {
    "type": "Number"
  },
  "95%": {
    "type": "Number"
  },
  "iqr": {
    "type": "Number"
  },
  "cv": {
    "type": "Number"
  },
  "p_zeros": {
    "type": "Number"
  },
  "p_infinite": {
    "type": "Number"
  },
  "monotonic_increase": {
    "type": "String"
  },
  "monotonic_decrease": {
    "type": "String"
  },
  "monotonic_increase_strict": {
    "type": "String"
  },
  "monotonic_decrease_strict": {
    "type": "String"
  },
  "monotonic": {
    "type": "Number"
  },
  "histogram": {
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
  "column": {
    "type": "String"
  }
});

const numeric_series_descriptions = new mongoose.Schema({
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
    "type": numeric_type
  }
});

module.exports = mongoose.model('numeric_series_descriptions', numeric_series_descriptions);

