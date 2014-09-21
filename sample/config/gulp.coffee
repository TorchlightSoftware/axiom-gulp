module.exports = ->
  custom: [
      src: @rel 'vendor/foo/foo.min.js'
      dest: 'vendor/foo.js'
    ,
  ]

  clientConfig:
    foo: 1
    bar: 'some value'
