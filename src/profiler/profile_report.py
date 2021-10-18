import copy
import json
import warnings
from pathlib import Path
from typing import Any, Dict, Optional, Union

import numpy as np
import pandas as pd
import yaml
from tqdm.auto import tqdm
from visions import VisionsTypeset

from src.profiler.config import Settings, Config
from src.profiler.model.sample import Sample
from src.profiler.model.summarizer import BaseSummarizer, PandasProfilingSummarizer
from src.profiler.model.typeset import ProfilingTypeSet
from src.profiler.utils.df_utils import hash_dataframe
from src.profiler.utils.paths import get_config
from src.profiler.model.describe import describe as describe_df

class ProfileReport():
    """Generate a profile report from a Dataset stored as a pandas `DataFrame`.
    """

    _description_set = None
    _report = None
    _json = None
    config: Settings

    def __init__(
            self,
            df: Optional[pd.DataFrame] = None,
            sample: Optional[dict] = None,
            config_file: Union[Path, str] = None,
            typeset: Optional[VisionsTypeset] = None,
            summarizer: Optional[BaseSummarizer] = None,
            config: Optional[Settings] = None,
            **kwargs,
    ):
        if df is None:
            raise ValueError("Can init a ProfileReport with no DataFrame")

        report_config: Settings = Settings() if config is None else config

        if config_file:
            if not config_file:
                config_file = get_config("minimal.yaml")

            with open(config_file) as f:
                data = yaml.safe_load(f)

            report_config = report_config.parse_obj(data)

        if len(kwargs) > 0:
            report_config = report_config.update(Config.shorthands(kwargs))

        self.df = df
        self.config = report_config
        self._df_hash = None
        self._sample = sample
        self._summarizer = summarizer

    @property
    def typeset(self) -> Optional[VisionsTypeset]:
        if self._typeset is None:
            self._typeset = ProfilingTypeSet(self.config)
        return self._typeset

    @property
    def summarizer(self) -> BaseSummarizer:
        if self._summarizer is None:
            self._summarizer = PandasProfilingSummarizer(self.typeset)
        return self._summarizer

    @property
    def description_set(self) -> Dict[str, Any]:
        if self._description_set is None:
            self._description_set = describe_df(
                self.config,
                self.df,
                self.summarizer,
                self.typeset,
                self._sample,
            )
        return self._description_set

    @property
    def df_hash(self) -> Optional[str]:
        if self._df_hash is None and self.df is not None:
            self._df_hash = hash_dataframe(self.df)
        return self._df_hash

    @property
    def json(self) -> str:
        if self._json is None:
            self._json = self._render_json()
        return self._json

    def to_json(self) -> str:
        """Represent the ProfileReport as a JSON string
        Returns:
            JSON string
        """

        return self.json

    def _render_json(self):
        def encode_it(o: Any) -> Any:
            if isinstance(o, dict):
                return {encode_it(k): encode_it(v) for k, v in o.items()}
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

        description = self.description_set

    def __repr__(self) -> str:
        """Override so that does not print the object."""
        return ""