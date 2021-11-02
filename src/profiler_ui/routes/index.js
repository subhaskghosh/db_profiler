const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();

const dbTable = mongoose.model('tables');
const alerts = mongoose.model('alerts');
const variables = mongoose.model('variables');
const samples = mongoose.model('samples');
const table_stats = mongoose.model('table_stats');
const numeric_series_descriptions = mongoose.model('numeric_series_descriptions');
const categorical_series_descriptions = mongoose.model('categorical_series_descriptions');
const boolean_series_descriptions = mongoose.model('boolean_series_descriptions');
const unsupported_series_descriptions = mongoose.model('unsupported_series_descriptions');
const missings = mongoose.model('missings');
const correlations = mongoose.model('correlations');
const scatter_matrices = mongoose.model('scatter_matrices');
const svg64 = require('svg64');


const convertSVG = function(im) {
    return svg64(im);
}

const roundDecimal = function(a) {
    return Math.round((a + Number.EPSILON) * 100) / 100
}

const formatBytes = function(bytes, decimals = 2) {
    if (bytes === 0) return '0 Bytes';

    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
}

router.get('/', (req, res) => {
  dbTable.find()
    .then((dbtables) => {
      res.render('index', { dbtables });
    })
    .catch(() => { res.send('Sorry! Something went wrong.'); });
});

router.get('/profile/:schema/:table', (req, res) => {
    var schema = req.params.schema
    var table = req.params.table
    Promise.all([
        table_stats.findOne({'analysis.schema':schema, 'analysis.table':table}),
        variables.findOne({'analysis.schema':schema, 'analysis.table':table}),
        alerts.findOne({'analysis.schema':schema, 'analysis.table':table}),
        samples.findOne({'analysis.schema':schema, 'analysis.table':table}),
        numeric_series_descriptions.find({'analysis.schema':schema, 'analysis.table':table}),
        categorical_series_descriptions.find({'analysis.schema':schema, 'analysis.table':table}),
        boolean_series_descriptions.find({'analysis.schema':schema, 'analysis.table':table}),
        unsupported_series_descriptions.find({'analysis.schema':schema, 'analysis.table':table}),
        missings.find({'analysis.schema':schema, 'analysis.table':table}),
        correlations.find({'analysis.schema':schema, 'analysis.table':table}),
        scatter_matrices.findOne({'analysis.schema':schema, 'analysis.table':table})
    ])
    .then((result) => {
        const [tableStats,
                variables,
                stringAlerts,
                profileSamples,
                numeric_series_descriptions,
                categorical_series_descriptions,
                boolean_series_descriptions,
                unsupported_series_descriptions,
                missings,
                correlations,
                scatter_matrices] = result;

        // Parse the alerts and add them to the series_descriptions
        var profileAlerts = {};
        profileAlerts['alerts'] = [];
        inx = 0;
        for (const alert of stringAlerts.alerts){
            var alrt = {};
            split_alert = alert.split("|");
            type_alert = split_alert[0].replace('_', ' ');
            col_alert = split_alert[1];
            num_alert = split_alert[2];

            columns = split_alert.slice(3,split_alert.length)

            alrt['type'] = type_alert;
            alrt['column'] = col_alert;
            alrt['num'] = num_alert;
            alrt['columns'] = columns;
            profileAlerts['alerts'][inx] = alrt;
            inx = inx + 1;
        }

        for (const column_description of numeric_series_descriptions) {
            column_description.result['alerts'] = [];
            column_description.result['column'] = column_description.variable
            index = 0;
            for (const alert of profileAlerts.alerts){
                if (alert.column == column_description.variable) {
                    column_description.result['alerts'][index] = alert.type;
                    index = index + 1;
                }
            }
        }

        for (const column_description of categorical_series_descriptions) {
            column_description.result['alerts'] = [];
            column_description.result['column'] = column_description.variable
            index = 0;
            for (const alert of profileAlerts.alerts){
                if (alert.column == column_description.variable) {
                    column_description.result['alerts'][index] = alert.type;
                    index = index + 1;
                }
            }
        }

        for (const column_description of boolean_series_descriptions) {
            column_description.result['alerts'] = [];
            column_description.result['column'] = column_description.variable
            index = 0;
            for (const alert of profileAlerts.alerts){
                if (alert.column == column_description.variable) {
                    column_description.result['alerts'][index] = alert.type;
                    index = index + 1;
                }
            }
        }

        for (const column_description of unsupported_series_descriptions) {
            column_description.result['alerts'] = [];
            column_description.result['column'] = column_description.variable
            index = 0;
            for (const alert of profileAlerts.alerts){
                if (alert.column == column_description.variable) {
                    column_description.result['alerts'][index] = alert.type;
                    index = index + 1;
                }
            }
        }

        //console.log(series_descriptions.Numeric[1].sample)
        res.render('profile', {schema,
                                table,
                                tableStats,
                                variables,
                                profileAlerts,
                                profileSamples,
                                numeric_series_descriptions,
                                categorical_series_descriptions,
                                boolean_series_descriptions,
                                unsupported_series_descriptions,
                                missings,
                                correlations,
                                scatter_matrices,
                                formatBytes,
                                roundDecimal,
                                convertSVG});
    })
    .catch((err) => {
        console.log(err);
        res.send('Sorry! Something went wrong.');
    });
});

router.get('/profile/:schema/:table/:from/:to', (req, res) => {
    var schema = req.params.schema;
    var table = req.params.table;
    var from = req.params.from;
    var to = req.params.to;

    scatter_matrices.findOne({'analysis.schema':schema, 'analysis.table':table, 'from_column':from, 'to_column':to})
        .then((result) => {
            var back = {
                'from_column': result.from_column,
                'to_column': result.to_column,
                'graph': convertSVG(result.graph)
            };

            res.json(back);
        })
        .catch(() => { res.json({'from_column': '',
                'to_column': '',
                'graph': ''}); });
});

router.post('/scan', (req, res) => {
    console.log(req.body);
    var pgurl = req.body.pgurl;
    var schema = req.body.schema;
    var table  = req.body.table;
    var mongourl = req.body.mongourl;
    var extraconfig = '--config_file /Users/ghoshsk/src/ds/db_profiler/src/pandas_profiling/config_default.yaml'

    const spawn = require("child_process").spawn;
    const pythonProcess = spawn('python',[process.env.PYCONSOLE, pgurl, schema, table, mongourl, extraconfig]);

    dbTable.find()
    .then((dbtables) => {
      res.render('index', { dbtables });
    })
    .catch(() => { res.send('Sorry! Something went wrong.'); });
});

module.exports = router;