from setuptools import setup
from pathlib import Path

source_root = Path(".")

# Read the requirements
with (source_root / "requirements.txt").open(encoding="utf8") as f:
    requirements = f.readlines()

setup(
    name='db_profiler',
    version='1.0',
    packages=['pandas_profiling', 'pandas_profiling.model', 'pandas_profiling.model.pandas', 'pandas_profiling.utils',
              'pandas_profiling.report', 'pandas_profiling.report.structure',
              'pandas_profiling.report.structure.variables', 'pandas_profiling.report.presentation',
              'pandas_profiling.report.presentation.core', 'pandas_profiling.report.presentation.flavours',
              'pandas_profiling.report.presentation.flavours.html',
              'pandas_profiling.report.presentation.flavours.widget', 'pandas_profiling.controller',
              'pandas_profiling.visualisation'],
    package_dir={'': 'src'},
    url='',
    python_requires=">=3.7",
    install_requires=requirements,
    license='Copyright GTM.ai, 2021',
    author='Subhas K Ghosh',
    author_email='subhas.ghosh@salesdna.ai',
    description='Profiler and UI'
)
