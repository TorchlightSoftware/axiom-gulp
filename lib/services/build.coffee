logger = require 'torch'
fs = require 'fs-extra'
rimraf = require 'rimraf'
_ = require 'lodash'
{focus} = require 'qi'
async = require 'async'
{join} = require 'path'

gulp = require 'gulp'
amd = require 'gulp-wrap-amd'
coffee = require 'gulp-coffee'
jade = require 'gulp-jade'
rename = require 'gulp-rename'

#oldEmit = gulp.emit
#gulp.emit = (args...) ->
  #logger.gray 'Emitting:', args...
  #oldEmit gulp, args...

module.exports =
  service: (args, done) ->

    #buildClientConfig = =>
      #copyToClient = @config.copyToClient or ['port', 'url', 'api']
      #clientConfig = JSON.stringify _.pick @config, copyToClient
      #return "define(#{clientConfig});"

    clientDir = @rel 'client'
    publicDir = @rel 'public'

    gulp.task 'clean', (next) ->
      rimraf publicDir, next

    gulp.task 'default', [
      'mkpublic'
      'compile'
      'static-files'
      'custom'
      'client-config'
    ]

    gulp.task 'mkpublic', ['clean'], (next) ->
      fs.mkdir publicDir, next

    gulp.task 'compile', ['clean', 'coffee', 'templates']

    #gulp.task 'client-config', ['public'], (fin) ->
      #clientConfig = buildClientConfig()
      #fs.writeFileSync join(publicDir, 'js/config.js'), clientConfig
      #fin()

    gulp.task 'client-config', ['clean'], (fin) =>

      if @config.clientConfig?
        out = "define(#{JSON.stringify(@config.clientConfig)});"
        fs.mkdirp @rel('public/js'), (err) =>
          return fin(err) if err?
          fs.writeFile @rel('public/js/config.js'), out, fin

      else
        fin()

    gulp.task 'custom', ['clean'], (fin) =>
      runBuild = (spec, next) ->
        {src, dest} = spec

        task = gulp.src(src)
        if dest?
          task = task.pipe(rename(dest))
        task.pipe(gulp.dest(publicDir)).on 'end', next

      async.forEach @config.custom, runBuild, fin

    gulp.task 'static-files', ['clean'], (fin) ->
      step = focus(fin)

      gulp.src(join(clientDir, '**/*.html'))
        .pipe(gulp.dest(publicDir)).on 'end', step()

      gulp.src(join(clientDir, '**/*.js'))
        .pipe(gulp.dest(publicDir)).on 'end', step()

      gulp.src(join(clientDir, '**/*.css'))
        .pipe(gulp.dest(publicDir)).on 'end', step()

      gulp.src(join clientDir, 'media/**')
          .pipe(gulp.dest(join publicDir, 'media')).on 'end', step()

      return null

    ## gulp.task 'template-runtime', ['public'], (fin) ->
    ##   src = join nodeModules, 'jade/runtime.js'
    ##   dest = join publicDir, 'js/vendor/jade-runtime.js'
    ##   fs.createReadStream(src).pipe(fs.createWriteStream(dest))
    ##   fin()

    gulp.task 'templates', ['mkpublic'], ->
      gulp.src("#{clientDir}/**/*.jade")
          .pipe(jade({
            client: true
            compileDebug: false
          }))
          .pipe(amd())
          .pipe(gulp.dest(publicDir))

    gulp.task 'coffee', ['mkpublic'], ->
      gulp.src("#{clientDir}/**/*.coffee")
          .pipe(coffee({bare: true}))
          .pipe(gulp.dest(publicDir))

    #gulp.task 'components/bower_components', (fin) =>
      #components = @app.components.bower_components or []
      #for {src, dest} in components
        #fs.createReadStream(join bowerComponents, src)
          #.pipe(fs.createWriteStream(join publicDir, 'js/vendor', dest))
      #fin()

    #gulp.task 'components/node_modules', (fin) =>
      #components = @app.components.node_modules or []
      #for {src, dest} in components
        #fs.createReadStream(join nodeModules, src)
          #.pipe(fs.createWriteStream(join publicDir, 'js/vendor', dest))
      #fin()

    #gulp.task 'components/flight', (fin) =>
      #return fin() unless @app.components.flight

      ## Copy globbed flight files
      #gulp.src(join bowerComponents, 'flight/lib/*.js')
          #.pipe(gulp.dest(join publicDir, 'js/vendor/flight'))
      #fin()

    #gulp.task 'components', [
      #'components/bower_components'
      #'components/node_modules'
      #'components/flight'
    #], (fin) -> fin()

    #rimraf publicDir, (err) ->
      #done(err) if err
    gulp.start 'default', done
