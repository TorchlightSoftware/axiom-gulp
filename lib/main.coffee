law = require 'law'
{join} = require 'path'

rel = (args...) -> join __dirname, args...

module.exports =
  config:

    # NOTE: not actually implemented just an idea
    pipeline:

      # file extension
      coffee: [

        # gulp modules
        'coffee'
      ]

      jade: [
        'jade'
      ]

    custom: []

  extends:
    build: ['client.build/load']

  services: law.load rel('services')
