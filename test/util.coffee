webdriver = require 'webdriverio'

exports.getBrowser = ->
  caps =
    browserName:       process.env.BROWSER ? 'phantomjs'
    platform:          process.env.PLATFORM
    version:           process.env.VERSION
    deviceName:        process.env.DEVICE_NAME
    deviceOrientation: process.env.DEVICE_ORIENTATION

  logLevel = if process.env.VERBOSE == 'true' then 'verbose' else 'silent'

  opts =
    desiredCapabilities: caps
    logLevel: logLevel

  if process.env.TRAVIS?
    { BS_AUTHKEY
      BS_AUTOMATE_BUILD
      BS_AUTOMATE_PROJECT
      BS_USERNAME
      TRAVIS_BRANCH
      TRAVIS_BUILD_NUMBER
      TRAVIS_COMMIT
      TRAVIS_JOB_NUMBER
      TRAVIS_PULL_REQUEST } = process.env

    # annotate tests with travis info
    caps.name = TRAVIS_COMMIT
    caps.tags = [
      TRAVIS_BRANCH
      TRAVIS_BUILD_NUMBER
      TRAVIS_PULL_REQUEST
    ]

    caps['tunnel-identifier'] = TRAVIS_JOB_NUMBER

    caps.project = BS_AUTOMATE_PROJECT
    caps.build = BS_AUTOMATE_BUILD

    opts =
      desiredCapabilities: caps
      logLevel: logLevel
      host: 'hub.browserstack.com/wd/hub'
      port: 80
      user: BS_USERAME
      key:  BS_AUTHKEY

  webdriver.remote(opts).init()
