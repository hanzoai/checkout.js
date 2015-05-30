exec = require('executive').interactive

task 'build', 'Build module and bundled checkout.js', ->
  exec 'node_modules/.bin/coffee -bcm -o lib/ src/'
  exec 'node_modules/.bin/requisite src/checkout.coffee -o checkout.js'
  exec 'node_modules/.bin/requisite src/checkout.coffee -m -o checkout.min.js'

task 'watch', 'watch for changes and recompile', ->
  exec 'node_modules/.bin/bebop'

task 'deploy', 'deploy new version', ->
  exec [
    'cake build'
    'git commit -am "Updated generated files"'
    'git pull --tags'
    'npm version patch'
    'git push'
    'git push --tags'
  ]
