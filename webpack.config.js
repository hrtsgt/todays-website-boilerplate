'use strict'

const path = require('path');
const webpack = require("webpack");
const env = process.env.NODE_ENV;

let config = {
	entry: {
		app: './src/ts/main.ts'
	},
	output: {
		path: __dirname,
		filename: 'bundle.js'
	},
	resolve: {
		extensions: ['.ts', '.webpack.js', '.web.js', '.js']
	},

	module: {
		loaders: [
			{ test: /\.ts$/, loader: 'awesome-typescript-loader'}
		]
	},

	plugins: [
		new webpack.DefinePlugin({
			'process.env.NODE_ENV': JSON.stringify(env)
		}),
		new webpack.optimize.OccurrenceOrderPlugin(),
	]
}

if( env === 'build'){
	config.plugins.push( new webpack.optimize.UglifyJsPlugin({
			compress:{ warnings:false}
		}));
}else{
	config.devtool = 'source-map';
}

module.exports = config;