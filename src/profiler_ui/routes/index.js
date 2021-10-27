const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();

const dbTable = mongoose.model('tables');
const alerts = mongoose.model('alerts');
const samples = mongoose.model('samples');
const table_stats = mongoose.model('table_stats');
const series_descriptions = mongoose.model('series_descriptions');
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
        alerts.findOne({'analysis.schema':schema, 'analysis.table':table}),
        samples.findOne({'analysis.schema':schema, 'analysis.table':table}),
        series_descriptions.findOne({'analysis.schema':schema, 'analysis.table':table}),
        missings.findOne({'analysis.schema':schema, 'analysis.table':table}),
        correlations.findOne({'analysis.schema':schema, 'analysis.table':table}),
        scatter_matrices.findOne({'analysis.schema':schema, 'analysis.table':table})
    ])
    .then((result) => {
        const [tableStats, profileAlerts, profileSamples, series_descriptions, missings, correlations, scatter_matrices] = result;
        //console.log(scatter_matrices)
        res.render('profile', {schema,
                                table,
                                tableStats,
                                profileAlerts,
                                profileSamples,
                                series_descriptions,
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

module.exports = router;