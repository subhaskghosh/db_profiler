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
  "character_counts": {type : Array , "default" : []},
  "category_alias_values": {type : Array , "default" : []},
  "block_alias_values": {type : Array , "default" : []},
  "block_alias_counts": {type : Array , "default" : []},
  "n_block_alias": {
    "type": "Number"
  },
  "block_alias_char_counts": {type : Array , "default" : []},
  "script_counts": {type : Array , "default" : []},
  "n_scripts": {
    "type": "Number"
  },
  "script_char_counts": {type : Array , "default" : []},
  "category_alias_counts": {type : Array , "default" : []},
  "n_category": {
    "type": "Number"
  },
  "category_alias_char_counts": {type : Array , "default" : []},
  "word_counts": {type : Array , "default" : []},
  "word_counts_graph": {
    "type": "String"
  },
  "column": {
    "type": "String"
  }
});

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
  "mode": {
    "type": "String"
  },
  "column": {
    "type": "String"
  }
});

const unsupported_type = new mongoose.Schema({
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
  "column": {
    "type": "String"
  }
});

const series_descriptions = new mongoose.Schema({
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
  "Numeric": {
    "type": [
      numeric_type
    ],
    "default" : []
  },
  "Categorical": {
    "type": [
      categorical_type
    ],
    "default" : []
  },
  "Boolean": {
    "type": [
      booleaan_type
    ],
    "default" : []
  },
  "Unsupported": {
    "type": [
      unsupported_type
    ],
    "default" : []
  }
});

module.exports = mongoose.model('series_descriptions', series_descriptions);

