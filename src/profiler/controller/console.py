"""This file add the console interface to the package."""
import argparse
from pathlib import Path
from typing import Any, List, Optional

def parse_args(args: Optional[List[Any]] = None) -> argparse.Namespace:
    """Parse the command line arguments for the profiling.
    Args:
      args: List of input arguments. (Default value=None).
    Returns:
      Namespace with parsed arguments.
    """
    parser = argparse.ArgumentParser(
        description="Profile the tables in a db and store in a mongodb collection."
    )

    parser.add_argument(
        "--config_file",
        type=str,
        default=None,
        help="Specify a yaml config file. Have a look at the 'default.yaml' as a starting point.",
    )

    parser.add_argument(
        "--source",
        type=str,
        default=None,
        help="Specify a data source. Have a look at the source.yaml as a starting point.",
    )

    parser.add_argument(
        "--sink",
        type=str,
        default=None,
        help="Specify a sink database (mongodb for now). Have a look at the sink.yaml for reference."
    )

    return parser.parse_args(args)


def main(args: Optional[List[Any]] = None) -> None:
    """Run the `profiling`.
    Args:
      args: Arguments for the programme (Default value=None).
    """

    # Parse the arguments
    parsed_args = parse_args(args)
    kwargs = vars(parsed_args)

    input_db_connection_string = Path(kwargs.pop("input_db"))
    output_db_connection_string = kwargs.pop("output_db")

    config_file_path = Path(kwargs.pop("config_file"))
    source_file_path = Path(kwargs.pop("source"))
    sink_file_path = Path(kwargs.pop("sink"))

    # read the db

    # create a df

    # Generate the profiling report

    # Publish the jsons in the output db collection