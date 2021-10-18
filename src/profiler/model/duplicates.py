from typing import Any, Dict, Optional, Sequence, Tuple, TypeVar

from multimethod import multimethod

from src.profiler.config import Settings

T = TypeVar("T")


@multimethod
def get_duplicates(
    config: Settings, df: T, supported_columns: Sequence
) -> Tuple[Dict[str, Any], Optional[T]]:
    raise NotImplementedError()
