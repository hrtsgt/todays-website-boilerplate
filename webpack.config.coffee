'use strict'

webpack = require 'webpack'
env = process.env.NODE_ENV

config =
	entry:
		app: './src/ts/main.ts'
	output:
		path: __dirname
		filename: 'bundle.js'
	module:
		loaders: [
			test: /\.ts$/
			loader: 'awesome-typescript-loader'
			exclude: /node_modules/
		]
	plugins: [
		new webpack.DefinePlugin
			'process.env.NODE_DEV': JSON.stringify(env)
	]

if env is 'build'
	config.plugins.push new webpack.optimize.UglifyJsPlugin {
		compress:
			warnings: false
			drop_console: false
	}
else
	config.devtool = 'source-map'

module.exports = config