law = require 'law'
{join} = require 'path'

rel = (args...) -> join __dirname, args...

module.exports =
  config:
    build:
      # In object pairs with keys ['src', 'dest']
      components: [
      ]

      # Project root directory
      root: null

      public: null

      coffee:
        src: null
        dest: null

  services: law.load rel('services')