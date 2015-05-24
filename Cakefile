exec = require('executive').interactive

task 'build', 'Build node module and prodocution minified bundle', ->
  exec 'node_modules/.bin/bebop --compile-only'
  exec 'node_modules/.bin/coffee -bcm -o lib/ src/'

task 'watch', 'watch for changes and recompile', ->
  exec 'node_modules/.bin/bebop'
