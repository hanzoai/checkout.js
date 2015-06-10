exec = require('executive').interactive
fork = require('child_process').fork
selenium = require 'selenium-standalone'

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

task 'install-selenium', 'installs chromedriver for selenium', ->
  selenium.install(
    version: '2.46.0'
    baseURL: 'http://selenium-release.storage.googleapis.com'
    drivers:
      chrome:
        version: '2.9'
        arch: process.arch
        baseURL: 'http://chromedriver.storage.googleapis.com'
    logger: console.log
    , (err) -> throw err if err?
  )

task 'test', 'run checkout widget test', ->
  exec [
    'mocha test/test.js'
  ]

