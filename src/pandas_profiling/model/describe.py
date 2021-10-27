"""Organize the calculation of statistics for each series in this DataFrame."""
import json
from datetime import datetime
from typing import Any, Dict, Optional
import matplotlib.pyplot as plt
from io import StringIO
import pandas as pd
import numpy as np
import base64
from pymongo.collection import Collection
from pymongo.database import Database
from tqdm.auto import tqdm
from visions import VisionsTypeset
import operator
from pandas_profiling.config import Settings
from pandas_profiling.model.alerts import get_alerts
from pandas_profiling.model.correlations import (
    calculate_correlation,
    get_active_correlations,
)
from pandas_profiling.model.dataframe import check_dataframe, preprocess
from pandas_profiling.model.duplicates import get_duplicates
from pandas_profiling.model.missing import get_missing_active, get_missing_diagram
from pandas_profiling.model.pairwise import get_scatter_plot, get_scatter_tasks
from pandas_profiling.model.sample import get_custom_sample, get_sample, Sample
from pandas_profiling.model.summarizer import BaseSummarizer, format_summary
from pandas_profiling.model.summary import get_series_descriptions
from pandas_profiling.model.table import get_table_stats
from pandas_profiling.utils.progress_bar import progress
from pandas_profiling.version import __version__

def encode_it(o: Any, t: str='value') -> Any:
    if isinstance(o, dict):
        return {encode_it(k, 'key'): encode_it(v) for k, v in o.items()}
    else:
        if t == 'key':
            return str(o)
        else:
            if isinstance(o, (bool, int, float, str)):
                return o
            elif isinstance(o, list):
                return [encode_it(v) for v in o]
            elif isinstance(o, set):
                return {encode_it(v) for v in o}
            elif isinstance(o, (pd.DataFrame, pd.Series)):
                return encode_it(o.to_dict(orient="records"))
            elif isinstance(o, np.ndarray):
                return encode_it(o.tolist())
            elif isinstance(o, Sample):
                return encode_it(o.dict())
            elif isinstance(o, np.generic):
                return o.item()
            else:
                return str(o)

def describe(
    config: Settings,
    df: pd.DataFrame,
    summarizer: BaseSummarizer,
    typeset: VisionsTypeset,
    sample: Optional[dict] = None,
    target: Database = None,
    target_schema: str = None,
    target_table: str = None
) -> dict:
    """Calculate the statistics for each series in this DataFrame.

    Args:
        config: report Settings object
        df: DataFrame.
        summarizer: summarizer object
        typeset: visions typeset
        sample: optional, dict with custom sample

    Returns:
        This function returns a dictionary containing:
            - table: overall statistics.
            - variables: descriptions per series.
            - correlations: correlation matrices.
            - missing: missing value diagrams.
            - alerts: direct special attention to these patterns in your data.
            - package: package details.
    """

    if df is None:
        raise ValueError("Can not describe a `lazy` ProfileReport without a DataFrame.")

    check_dataframe(df)
    df = preprocess(config, df)

    schemas_collection: Collection = target['schemas']
    tables_collection: Collection = target['tables']
    alerts_collection: Collection = target['alerts']
    correlations_collection: Collection = target['correlations']
    samples_collection: Collection = target['samples']
    missing_collection: Collection = target['missings']
    scatter_matrix_collection = target['scatter_matrices']
    series_description_collection = target['series_descriptions']
    table_stats_collection = target['table_stats']
    duplicates_collection = target['duplicates']
    variables_collection = target['variables']

    schemas_collection.delete_many({'schema':target_schema})
    tables_collection.delete_many({'schema': target_schema, 'table': target_table})
    alerts_collection.delete_many({'analysis.schema': target_schema, 'analysis.table': target_table})
    correlations_collection.delete_many({'analysis.schema':target_schema, 'analysis.table':target_table})
    samples_collection.delete_many({'analysis.schema': target_schema, 'analysis.table': target_table})
    missing_collection.delete_many({'analysis.schema': target_schema, 'analysis.table': target_table})
    scatter_matrix_collection.delete_many({'analysis.schema': target_schema, 'analysis.table': target_table})
    series_description_collection.delete_many({'analysis.schema': target_schema, 'analysis.table': target_table})
    table_stats_collection.delete_many({'analysis.schema': target_schema, 'analysis.table': target_table})
    duplicates_collection.delete_many({'analysis.schema': target_schema, 'analysis.table': target_table})
    variables_collection.delete_many({'analysis.schema': target_schema, 'analysis.table': target_table})

    number_of_tasks = 5

    with tqdm(
        total=number_of_tasks,
        desc="Summarize dataset",
        disable=not config.progress_bar,
        position=0,
    ) as pbar:
        date_start = datetime.utcnow()

        # Variable-specific
        pbar.total += len(df.columns)
        series_description = get_series_descriptions(
            config, df, summarizer, typeset, pbar
        )

        pbar.set_postfix_str("Get variable types")
        pbar.total += 1
        variables = {
            column: description["type"]
            for column, description in series_description.items()
        }
        supported_columns = [
            column
            for column, type_name in variables.items()
            if type_name != "Unsupported"
        ]
        interval_columns = [
            column for column, type_name in variables.items() if type_name == "Numeric"
        ]
        pbar.update()

        # Get correlations
        correlation_names = get_active_correlations(config)
        pbar.total += len(correlation_names)

        correlations = {
            correlation_name: progress(
                calculate_correlation, pbar, f"Calculate {correlation_name} correlation"
            )(config, df, correlation_name, series_description)
            for correlation_name in correlation_names
        }

        # make sure correlations is not None
        correlations = {
            key: value for key, value in correlations.items() if value is not None
        }

        # Scatter matrix
        pbar.set_postfix_str("Get scatter matrix")
        scatter_tasks = get_scatter_tasks(config, interval_columns)
        pbar.total += len(scatter_tasks)
        scatter_matrix: Dict[Any, Dict[Any, Any]] = {
            x: {y: None} for x, y in scatter_tasks
        }
        for x, y in scatter_tasks:
            scatter_matrix[x][y] = progress(
                get_scatter_plot, pbar, f"scatter {x}, {y}"
            )(config, df, x, y, interval_columns)

        # Table statistics
        table_stats = progress(get_table_stats, pbar, "Get dataframe statistics")(
            config, df, series_description
        )

        # missing diagrams
        missing_map = get_missing_active(config, table_stats)
        pbar.total += len(missing_map)
        missing = {
            name: progress(get_missing_diagram, pbar, f"Missing diagram {name}")(
                config, df, settings
            )
            for name, settings in missing_map.items()
        }
        missing = {name: value for name, value in missing.items() if value is not None}

        # Sample
        pbar.set_postfix_str("Take sample")
        if sample is None:
            samples = get_sample(config, df)
        else:
            samples = get_custom_sample(sample)
        pbar.update()

        # Duplicates
        metrics, duplicates = progress(get_duplicates, pbar, "Detecting duplicates")(
            config, df, supported_columns
        )
        table_stats.update(metrics)

        alerts = progress(get_alerts, pbar, "Get alerts")(
            config, table_stats, series_description, correlations
        )

        pbar.set_postfix_str("Get reproduction details")
        package = {
            "pandas_profiling_version": __version__,
            "pandas_profiling_config": config.json(),
        }

        date_end = datetime.utcnow()
        pbar.update()
        pbar.set_postfix_str("Completed")

    with tqdm(
            total=1, desc="Loading to MongoDB", disable=not config.progress_bar
    ) as pbar:

        analysis = {
            'schema': target_schema,
            'table': target_table,
            "title": f'{config.title} {target_schema}.{target_table}',
            "date_start": date_start,
            "date_end": date_end
        }

        schema = {'schema': target_schema, 'create_date': date_end}
        table = {'schema': target_schema, 'table': target_table, 'create_date': date_end}

        alrt = {}
        alrt["analysis"] = analysis
        alrt['alerts'] = alerts

        correlations["analysis"] = analysis
        missing["analysis"] = analysis
        table_stats["analysis"] = analysis

        sample = {}
        sample["analysis"] = analysis
        sample["sample"] = samples
        duplicates["analysis"] = analysis

        columns = {}
        columns['variables'] = variables
        columns['analysis'] = analysis

        schema = encode_it(format_summary(schema))
        table = encode_it(format_summary(table))
        alrt = encode_it(format_summary(alrt))
        correlations = encode_it(format_summary(correlations))
        missing = encode_it(format_summary(missing))
        table_stats = encode_it(format_summary(table_stats))
        series_description = encode_it(format_summary(series_description))
        scatter_matrix = encode_it(format_summary(scatter_matrix))
        sample = encode_it(format_summary(sample))
        duplicates = encode_it(format_summary(duplicates))
        columns = encode_it(format_summary(columns))

        update_series_description = {}
        for sd in series_description.items():
            sd[1]['column'] = sd[0]
            if sd[1]['type'] in update_series_description:
                update_series_description[sd[1]['type']].append(sd[1])
            else:
                update_series_description[sd[1]['type']] = [sd[1]]
        update_series_description["analysis"] = analysis

        update_scatter_matrix = {}
        update_scatter_matrix['matrix'] = []

        for k,v in scatter_matrix.items():
            entry = {}
            entry['from_column'] = k
            entry['tos'] = []
            for key, value in v.items():
                sub_entry = {}
                sub_entry['to_column'] = key
                sub_entry['graph'] = value
                entry['tos'].append(sub_entry)
            update_scatter_matrix['matrix'].append(entry)

        for k, v in series_description.items():
            histogram_data = None
            if 'histogram' in v:
                histogram_data = v['histogram']
            elif 'histogram_length' in v:
                histogram_data = v['histogram_length']
            if histogram_data:
                counts = histogram_data['counts']
                bin_edges = histogram_data['bin_edges']
                left_edges = bin_edges[:-1]

                width = 1.0
                if len(left_edges) > 1:
                    width = 0.85 * (left_edges[1] - left_edges[0])

                plt.bar(left_edges, counts, align='edge', width=width)
                image_str = StringIO()
                plt.savefig(image_str, format='svg')
                plt.close()
                result_string = image_str.getvalue()
                series_description[k]['histogram_graph'] = result_string

        for k, v in series_description.items():
            if "word_counts" in v:
                D = v['word_counts']
                Dt = dict(sorted(D.items(), key=operator.itemgetter(1), reverse=True)[:10])
                D = Dt
                plt.bar(range(len(D)), list(D.values()), align='center')
                plt.xticks(range(len(D)), list(D.keys()), rotation=25)
                image_str = StringIO()
                plt.savefig(image_str, format='svg')
                plt.close()
                result_string = image_str.getvalue()
                series_description[k]['word_counts_graph'] = result_string

        update_scatter_matrix["analysis"] = analysis
        schemas_collection.insert_one(schema)
        tables_collection.insert_one(table)
        alerts_collection.insert_one(alrt)
        correlations_collection.insert_one(correlations)
        missing_collection.insert_one(missing)
        table_stats_collection.insert_one(table_stats)
        series_description_collection.insert_one(update_series_description)
        scatter_matrix_collection.insert_one(update_scatter_matrix)
        samples_collection.insert_one(sample)
        duplicates_collection.insert_one(duplicates)
        variables_collection.insert_one(columns)

        pbar.update()

    return {
        # Analysis metadata
        # "analysis": analysis,
        # Overall dataset description
        # "table": table_stats,
        # # Per variable descriptions
        # "variables": series_description,
        # # Bivariate relations
        # "scatter": scatter_matrix,
        # # Correlation matrices
        # "correlations": correlations,
        # # Missing values
        # "missing": missing,
        # # Alerts
        # "alerts": alerts,
        # # Package
        # "package": package,
        # # Sample
        # "sample": samples,
        # # Duplicates
        # "duplicates": duplicates,
    }
