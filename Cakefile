exec = require('executive').interactive

task 'build', 'Build module and bundled checkout.js', ->
  exec 'node_modules/.bin/bebop --compile-only'
  exec 'node_modules/.bin/coffee -bcm -o lib/ src/'

task 'watch', 'watch for changes and recompile', ->
  exec 'node_modules/.bin/bebop'

task 'build-min', 'Build minified checkout.min.js', ->
  exec 'node_modules/.bin/requisite src/checkout.coffee -m -o checkout.min.js'
