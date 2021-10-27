"""This file add the console interface to the package."""
import argparse
import sys
from typing import Any, List, Optional
from sqlalchemy import create_engine
from pandas_profiling.__init__ import ProfileReport, __version__
import pandas as pd
from pymongo import MongoClient

def parse_args(args: Optional[List[Any]] = None) -> argparse.Namespace:
    """Parse the command line arguments for the `pandas_profiling` binary.

    Args:
      args: List of input arguments. (Default value=None).

    Returns:
      Namespace with parsed arguments.

    """
    parser = argparse.ArgumentParser(
        description="Profile the variables in a CSV file and generate a HTML report."
    )

    # Version
    parser.add_argument(
        "--version", action="version", version=f"%(prog)s {__version__}"
    )

    # Console specific
    parser.add_argument(
        "-s",
        "--silent",
        help="Only generate but do not open report",
        action="store_true",
    )

    parser.add_argument(
        "-m",
        "--minimal",
        help="Minimal configuration for big data sets",
        action="store_true",
    )

    parser.add_argument(
        "-e",
        "--explorative",
        help="Explorative configuration featuring unicode, file and image analysis",
        action="store_true",
    )

    # Config
    parser.add_argument(
        "--pool_size", type=int, default=0, help="Number of CPU cores to use"
    )
    parser.add_argument(
        "--title",
        type=str,
        default="Profiling Report For:",
        help="Title for the report",
    )

    parser.add_argument(
        "--infer_dtypes",
        default=False,
        action="store_true",
        help="To infer dtypes of the dataframe",
    )

    parser.add_argument(
        "--no-infer_dtypes",
        dest="infer_dtypes",
        action="store_false",
        help="To read dtypes as read by pandas",
    )

    parser.add_argument(
        "--config_file",
        type=str,
        default=None,
        help="Specify a yaml config file. Have a look at the 'config_default.yaml' as a starting point.",
    )

    parser.add_argument(
        "source_db_uri",
        type=str,
        default=None,
        help="postgres db uri",
    )

    parser.add_argument(
        "db_schema",
        type=str,
        default=None,
        help="postgres db schema",
    )

    parser.add_argument(
        "db_table",
        type=str,
        default=None,
        help="postgres db db_table",
    )

    parser.add_argument(
        "target_db_uri",
        type=str,
        default=None,
        help="Mongodb connection string",
    )

    return parser.parse_args(args)


def main(args: Optional[List[Any]] = None) -> None:
    """Run the `pandas_profiling` package.

    Args:
      args: Arguments for the programme (Default value=None).
    """

    # Parse the arguments
    parsed_args = parse_args(args)
    kwargs = vars(parsed_args)

    silent = kwargs.pop("silent")

    # get the SQLAlchemy uri, schema and table
    connection_uri = kwargs.pop("source_db_uri")
    db_schema = kwargs.pop("db_schema")
    db_table = kwargs.pop("db_table")
    target_connection_uri = kwargs.pop("target_db_uri")

    # Create the engine object
    engine = create_engine(connection_uri, echo=False)

    # read the DataFrame
    with engine.connect() as con:
        df = pd.read_sql_table(table_name=db_table, con=con, schema=db_schema)


    # Generate the profiling report
    p = ProfileReport(
        df,
        **kwargs,
    )
    # Create a target db client
    target_client = MongoClient(target_connection_uri)
    target_db = target_client['profile']

    p.set_target_db(target_db)
    p.set_schema_name(db_schema)
    p.set_table_name(db_table)

    # Start pushing the profile into MongoDB
    j = p.to_json()

if __name__ == "__main__":
   main(sys.argv[1:])