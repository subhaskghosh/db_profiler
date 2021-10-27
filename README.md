# db_profiler
A profiler based on pandas-profiling but connects to postgresql and then stores metadata to mongo with an API and UI interface

execute python ./pandas_profiling/controller/console.py postgresql+psycopg2://postgres:password@host:port/db schema table mongodb://host:27017/

UI:
![Page 1](src/docs/Screen.png)

![Page 2](src/docs/Screen-1.png)

![Page 3](src/docs/Screen-2.png)

![Page 4](src/docs/Screen-3.png)