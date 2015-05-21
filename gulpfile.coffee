gulp = require('gulp')
$ = require('gulp-load-plugins')()

browserSync = require('browser-sync')
reload = browserSync.reload
modRewrite = require('connect-modrewrite')

browserify = require('browserify')
envify = require('envify/custom')
source = require('vinyl-source-stream')

notifier = require('node-notifier')

nodeEnv = process.env.NODE_ENV || "development"

gulp.task 'browserify', ->

  b = browserify(
    entries: ['./app/scripts/main.coffee']
    extensions: [".coffee", ".vue", ".js"]
    transform: ['coffeeify', 'debowerify', 'vueify']
    debug: nodeEnv == "development"
  )

  b.transform(envify({
    env: require("./app/scripts/config/#{nodeEnv}")
  }))

  b.bundle()
    .on("error", (err) ->
      console.error err.message
      notifier.notify
        message: err.message,
        title: "browserify error"
      @emit("end")
    )
    .pipe(source('bundle.js'))
    .pipe(gulp.dest('.tmp/scripts'))
  

gulp.task 'styles', ->

  gulp.src('app/styles/main.sass')
    .pipe($.sourcemaps.init())
    .pipe($.sass(
      outputStyle: 'nested'
      precision: 10
      includePaths: ['.']
      indentedSyntax: true
      onError: console.error.bind(console, 'Sass error:')
    ))
    .pipe($.postcss([require('autoprefixer-core')(browsers: ['last 1 version'])]))
    .pipe($.sourcemaps.write())
    .pipe(gulp.dest('.tmp/styles'))
    .pipe(reload(stream: true))

gulp.task 'html', ['browserify', 'styles'], ->

  assets = $.useref.assets({searchPath: ['.tmp', 'app', '.']})
  
  gulp.src('app/*.html')
    .pipe(assets)
    .pipe($.if('*.js', $.uglify()))
    .pipe($.if('*.css', $.csso()))
    .pipe(assets.restore())
    .pipe($.useref())
    .pipe($.if('*.html', $.minifyHtml(conditionals: true, loose: true)))
    .pipe(gulp.dest('dist'))

gulp.task 'fonts', ->
  gulp.src(require('main-bower-files')(
    filter: '**/*.{eot,svg,ttf,woff,woff2}'
  ).concat('app/fonts/**/*'))
    .pipe(gulp.dest('.tmp/fonts'))
    .pipe(gulp.dest('dist/fonts'))

gulp.task 'serve', ['browserify', 'styles'], ->

  browserSync
    port: 9003
    server:
      baseDir: ['.tmp', 'app']
      routes:
        '/bower_components': 'bower_components'
      middleware: [modRewrite(['!\\.\\w+$ /index.html [L]'])]

  gulp.watch([
    'app/*.html'
    'app/scripts/**/*.js'
    '.tmp/scripts/**/*.js'
    '.tmp/templates/**/*.js'
    'app/images/**/*'
  ]).on 'change', reload

  gulp.watch 'app/styles/**/*.css', ['styles']
  gulp.watch 'app/scripts/**/*.coffee', ['browserify']
  gulp.watch 'app/scripts/**/*.vue', ['browserify']

gulp.task('clean', require('del').bind(null, ['.tmp', 'dist']))

gulp.task 'build', ['html', 'fonts'], ->
  gulp.src('dist/**/*')
    .pipe($.size(title: 'build', gzip: true))

gulp.task 'default', ['clean'], ->
  gulp.start 'build'
