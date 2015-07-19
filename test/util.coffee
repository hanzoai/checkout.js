webdriver = require 'webdriverio'

exports.getBrowser = ->
  browserName = process.env.BROWSER

  opts =
    desiredCapabilities:
      browserName: browserName ? 'phantomjs'

  if process.env.TRAVIS?
    opts =
      desiredCapabilities:
        browserName: browserName
        name: process.env.TRAVIS_COMMIT
        tags: [
          process.env.TRAVIS_PULL_REQUEST
          process.env.TRAVIS_BRANCH
          process.env.TRAVIS_BUILD_NUMBER
        ]
        'tunnel-identifier': process.env.TRAVIS_JOB_NUMBER
      host: 'ondemand.saucelabs.com'
      port: 80
      user: process.env.SAUCE_USERNAME
      key: process.env.SAUCE_ACCESS_KEY
      logLevel: 'silent'

  webdriver.remote(opts).init()
