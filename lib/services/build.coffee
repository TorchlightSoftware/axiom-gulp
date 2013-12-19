logger = require 'torch'
fs = require 'fs'
gulp = require 'gulp'
amd = require 'gulp-wrap-amd'
coffee = require 'gulp-coffee'
jade = require 'gulp-jade'
rimraf = require 'gulp-rimraf'

{join} = require 'path'

module.exports =
  service: (args, done) ->

    buildClientConfig = =>
      {publicPort, url, api} = @app
      clientConfig = JSON.stringify {publicPort, url, api}
      result = "define(#{clientConfig});"
      return result

    clientDir = @util.rel 'app/client'
    publicDir = @util.rel 'app/public'

    nodeModules = @util.rel 'node_modules'
    bowerComponents = @util.rel 'bower_components'

    templateSrc = join clientDir, 'templates'
    templateDest = join publicDir, 'templates'

    coffeeSrc = join clientDir, 'js'
    coffeeDest = join publicDir, 'js'

    gulp.task 'default', (fin) ->
      gulp.run [
        'public'
        'client-config'
        'components'
        # 'template-runtime'
        'templates'
        'coffee'
        'static-files'
      ]...
      fin()

    gulp.task 'clean', (fin) ->
      gulp.src(publicDir).pipe(rimraf())
      fin()

    gulp.task 'public', ['clean'], (fin) ->
      unless fs.existsSync publicDir
        fs.mkdirSync publicDir
      for p in ['templates', 'js', 'js/vendor', 'js/vendor/flight', 'css', 'img']
        dir = join(publicDir, p)
        unless fs.existsSync dir
          fs.mkdirSync dir
      fin()

    gulp.task 'client-config', ['public'], (fin) ->
      clientConfig = buildClientConfig()
      fs.writeFileSync join(publicDir, 'js/config.js'), clientConfig
      fin()

    gulp.task 'static-files', ['components'], (fin) ->
      gulp.src(join clientDir, '*.html')
          .pipe(gulp.dest(publicDir))

      gulp.src(join clientDir, 'js/vendor/**')
          .pipe(gulp.dest(join publicDir, 'js/vendor'))

      gulp.src(join clientDir, 'css/**')
          .pipe(gulp.dest(join publicDir, 'css'))

      gulp.src(join clientDir, 'img/**')
          .pipe(gulp.dest(join publicDir, 'img'))

      fin()

    # gulp.task 'template-runtime', ['public'], (fin) ->
    #   src = join nodeModules, 'jade/runtime.js'
    #   dest = join publicDir, 'js/vendor/jade-runtime.js'
    #   fs.createReadStream(src).pipe(fs.createWriteStream(dest))
    #   fin()

    gulp.task 'templates', ['public'], (fin) ->
      gulp.src(join templateSrc, '*.jade')
          .pipe(jade({
            client: true
            compileDebug: false
          }))
          .pipe(amd())
          .pipe(gulp.dest(templateDest))
      fin()

    gulp.task 'coffee', [], (fin) ->
      gulp.src(join coffeeSrc, '/**/*.coffee')
          .pipe(coffee({bare: true}))
          .pipe(gulp.dest(coffeeDest))
      fin()

    gulp.task 'components/bower_components', (fin) =>
      components = @app.components.bower_components or []
      for {src, dest} in components
        fs.createReadStream(join bowerComponents, src)
          .pipe(fs.createWriteStream(join publicDir, 'js/vendor', dest))
      fin()

    gulp.task 'components/node_modules', (fin) =>
      components = @app.components.node_modules or []
      for {src, dest} in components
        fs.createReadStream(join nodeModules, src)
          .pipe(fs.createWriteStream(join publicDir, 'js/vendor', dest))
      fin()

    gulp.task 'components/flight', (fin) =>
      return fin() unless @app.components.flight

      # Copy globbed flight files
      gulp.src(join bowerComponents, 'flight/lib/*.js')
          .pipe(gulp.dest(join publicDir, 'js/vendor/flight'))
      fin()

    gulp.task 'components', [
      'components/bower_components'
      'components/node_modules'
      'components/flight'
    ], (fin) -> fin()

    gulp.run 'default', done
