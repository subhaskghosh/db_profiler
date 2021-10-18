"""Utils for pandas DataFrames."""
import re
import unicodedata
from typing import Any, Optional

import joblib
import pandas as pd

def rename_index(df: pd.DataFrame) -> pd.DataFrame:
    """If the DataFrame contains a column or index named `index`, this will produce errors. We rename the {index,column}
    to be `df_index`.
    Args:
        df: DataFrame to process.
    Returns:
        The DataFrame with {index,column} `index` replaced by `df_index`, unchanged if the DataFrame does not contain such a string.
    """
    df.rename(columns={"index": "df_index"}, inplace=True)

    if "index" in df.index.names:
        df.index.names = [x if x != "index" else "df_index" for x in df.index.names]
    return df


def expand_mixed(df: pd.DataFrame, types: Any = None) -> pd.DataFrame:
    """Expand non-nested lists, dicts and tuples in a DataFrame into columns with a prefix.
    Args:
        types: list of types to expand (Default: list, dict, tuple)
        df: DataFrame
    Returns:
        DataFrame with the dict values as series, identifier by the combination of the series and dict keys.
    Notes:
        TODO: allow for list expansion by duplicating rows.
        TODO: allow for expansion of nested data structures.
    """
    if types is None:
        types = [list, dict, tuple]

    for column_name in df.columns:
        # All
        non_nested_enumeration = (
            df[column_name]
            .dropna()
            .map(lambda x: type(x) in types and not any(type(y) in types for y in x))
        )

        if non_nested_enumeration.all():
            # Expand and prefix
            expanded = pd.DataFrame(df[column_name].dropna().tolist())
            expanded = expanded.add_prefix(column_name + "_")

            # Add recursion
            expanded = expand_mixed(expanded)

            # Drop te expanded
            df.drop(columns=[column_name], inplace=True)

            df = pd.concat([df, expanded], axis=1)
    return df


def hash_dataframe(df: pd.DataFrame) -> str:
    """Hash a DataFrame (wrapper around joblib.hash, might change in the future)
    Args:
        df: the DataFrame
    Returns:
        The DataFrame's hash
    """
    return joblib.hash(df)


def slugify(value: str, allow_unicode: bool = False) -> str:
    """
    Taken from https://github.com/django/django/blob/master/django/utils/text.py
    Convert to ASCII if 'allow_unicode' is False. Convert spaces or repeated
    dashes to single dashes. Remove characters that aren't alphanumerics,
    underscores, or hyphens. Convert to lowercase. Also strip leading and
    trailing whitespace, dashes, and underscores.
    """
    value = str(value)
    if allow_unicode:
        value = unicodedata.normalize("NFKC", value)
    else:
        value = (
            unicodedata.normalize("NFKD", value)
            .encode("ascii", "ignore")
            .decode("ascii")
        )
    value = re.sub(r"[^\w\s-]", "", value.lower())
    return re.sub(r"[-\s]+", "-", value).strip("-_")


def sort_column_names(dct: dict, sort: Optional[str]) -> dict:
    if sort is None:
        return dct

    sort = sort.lower()
    if sort.startswith("asc"):
        dct = dict(sorted(dct.items(), key=lambda x: x[0].casefold()))
    elif sort.startswith("desc"):
        dct = dict(sorted(dct.items(), key=lambda x: x[0].casefold(), reverse=True))
    else:
        raise ValueError('"sort" should be "ascending", "descending" or None.')
    return dct