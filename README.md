# db_profiler
A profiler based on pandas-profiling but connects to postgresql and then stores metadata to mongo with an API and UI interface

- Install node 16
- cd profiler_ui - npm install
- Install mongodb
- modify .env
- npm run
- execute python ./pandas_profiling/controller/console.py postgresql+psycopg2://postgres:password@host:port/db schema table mongodb://host:27017/ --config_file
./pandas_profiling/config_default.yaml --infer_dtypes
- Will create profile

Note: Use --infer_dtypes on tables where datatypes are all text and you would like to infer them.

# profiler_ui
Node >= 16

dependency: 
- "dotenv": "^10.0.0",
- "express": "^4.17.1",
- "fast-xml-parser": "^3.21.0",
- "mongoose": "^6.0.11",
- "pug": "^3.0.2",
- "svg64": "^1.1.0"

# postgreSQLParser

antlrv4 ver. 4.9

## Getting Started with ANTLR v4

### Installation

ANTLR is really two things: a tool that translates your grammar to a parser/lexer in Java (or other target language) and the runtime needed by the generated parsers/lexers. Even if you are using the ANTLR Intellij plug-in or ANTLRWorks to run the ANTLR tool, the generated code will still need the runtime library. 

The first thing you should do is probably download and install a development tool plug-in. Even if you only use such tools for editing, they are great. Then, follow the instructions below to get the runtime environment available to your system to run generated parsers/lexers.  In what follows, I talk about antlr-4.9-complete.jar, which has the tool and the runtime and any other support libraries (e.g., ANTLR v4 is written in v3).

If you are going to integrate ANTLR into your existing build system using mvn, ant, or want to get ANTLR into your IDE such as eclipse or intellij, see [Integrating ANTLR into Development Systems](https://github.com/antlr/antlr4/blob/master/doc/IDEs.md).

#### UNIX

0. Install Java (version 1.7 or higher)
1. Download
```
$ cd /usr/local/lib
$ curl -O https://www.antlr.org/download/antlr-4.9-complete.jar
```
Or just download in browser from website:
    [https://www.antlr.org/download.html](https://www.antlr.org/download.html)
and put it somewhere rational like `/usr/local/lib`.

2. Add `antlr-4.9-complete.jar` to your `CLASSPATH`:
```
$ export CLASSPATH=".:/usr/local/lib/antlr-4.9-complete.jar:$CLASSPATH"
```
It's also a good idea to put this in your `.bash_profile` or whatever your startup script is.

3. Create aliases for the ANTLR Tool, and `TestRig`.
```
$ alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.9-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
$ alias grun='java -Xmx500M -cp "/usr/local/lib/antlr-4.9-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'
```