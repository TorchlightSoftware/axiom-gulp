law = require 'law'
{join} = require 'path'

rel = (args...) -> join __dirname, args...

module.exports =
  config:

    #copyToClient: ['key1', 'key2']

    pipeline:

      # file extension
      coffee: [

        # gulp modules
        'coffee'
      ]

      jade: [
        'jade'
      ]

  extends:
    build: ['client.build/load']

  services: law.load rel('services')
