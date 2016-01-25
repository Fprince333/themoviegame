gulp = require 'gulp'
gutil = require 'gulp-util'
webpack = require("webpack")
WebpackDevServer = require("webpack-dev-server")
webpackConfig = require("./webpack.config.js")
webpackProductionConfig = require("./webpack.production.config.js")
map = require 'map-stream'
touch = require 'touch'
_ = require 'underscore'

# Load plugins
$ = require('gulp-load-plugins')()

# CSS
gulp.task('css', ->
  gulp.src(['src/styles/*.sass', 'src/styles/*.scss'])
    .pipe($.compass({
      css: 'public/'
      sass: 'src/styles'
      image: 'src/styles/images'
      style: 'nested'
      comments: false
      bundle_exec: true
      time: true
      require: ['sass-css-importer']
    }))
    .on('error', (err) ->
      gutil.log err
    )
    .pipe($.size())
    .pipe(gulp.dest('public/'))
    .pipe(map((a, cb) ->
      if devServer.invalidate? then devServer.invalidate()
      cb()
    ))
)

gulp.task('copy-assets', ->
    gulp.src('assets/**')
      .pipe(gulp.dest('public'))
      .pipe($.size())
)

gulp.task "webpack:build", ['css'], (callback) ->
  # Run webpack.
  webpack webpackProductionConfig, (err, stats) ->
    throw new gutil.PluginError("webpack:build", err)  if err
    gutil.log "[webpack:build]", stats.toString(colors: true)
    callback()
    return


# Create a single instance of the compiler to allow caching.
devCompiler = webpack(webpackConfig)
gulp.task "webpack:build-dev", ['css'], (callback) ->

  # Run webpack.
  devCompiler.run (err, stats) ->
    throw new gutil.PluginError("webpack:build-dev", err)  if err
    gutil.log "[webpack:build-dev]", stats.toString(colors: true)
    callback()
    return

  return

devServer = {}
gulp.task "webpack-dev-server", ['css'], (callback) ->
  # Ensure there's a `./public/main.css` file that can be required.
  touch.sync('./public/main.css', time: new Date(0))

  # Start a webpack-dev-server.
  devServer = new WebpackDevServer(webpack(webpackConfig),
    contentBase: './public/'
    hot: true
    watchOptions:
        aggregateTimeout: 100
        poll: 300
    noInfo: true
  )
  devServer.listen 8080, "0.0.0.0", (err) ->
    throw new gutil.PluginError("webpack-dev-server", err) if err
    gutil.log "[webpack-dev-server]", "http://localhost:8080"
    callback()

  return

gulp.task 'default', ->
  gulp.start 'build'

gulp.task 'build', ['webpack:build', 'copy-assets']

gulp.task 'watch', ['css', 'copy-assets', 'webpack-dev-server'], ->
  gulp.watch(['src/styles/**'], ['css'])
  gulp.watch(['assets/**'], ['copy-assets'])
