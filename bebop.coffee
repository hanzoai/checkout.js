fs   = require 'fs'
path = require 'path'
exec = require('executive').interactive

requisite = 'node_modules/.bin/requisite -g'

compile = ->
  exec 'node_modules/.bin/coffee -bcm -o lib/ src/'
  exec 'node_modules/.bin/requisite src/checkout.coffee -o checkout.js'
  exec 'node_modules/.bin/requisite src/checkout.coffee -m -o checkout.min.js'

module.exports =
  port: 4242

  cwd: process.cwd()

  exclude: [
    /css/
    /lib/
    /node_modules/
    /vendor/
  ]

  compilers:
    coffee: (src) ->
      if /^src/.test src
        compile()

      if /src\/checkout.coffee/.test src
        compile()
