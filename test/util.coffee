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
      BS_USERNAME
      TRAVIS_BRANCH
      TRAVIS_BUILD_NUMBER
      TRAVIS_COMMIT
      TRAVIS_JOB_NUMBER
      TRAVIS_PULL_REQUEST
      TRAVIS_REPO_SLUG } = process.env

    # annotate tests with travis info
    caps.name = TRAVIS_COMMIT
    caps.tags = [
      TRAVIS_BRANCH
      TRAVIS_BUILD_NUMBER
      TRAVIS_PULL_REQUEST
    ]

    caps['tunnel-identifier'] = TRAVIS_JOB_NUMBER
    caps.project = TRAVIS_REPO_SLUG
    caps.build = "Travis (#{TRAVIS_BUILD_NUMBER}) for #{TRAVIS_REPO_SLUG}"

    caps['browserstack.debug'] = true

    opts =
      desiredCapabilities: caps
      logLevel: logLevel
      host: 'hub.browserstack.com'
      port: 80
      user: BS_USERNAME
      key:  BS_AUTHKEY

  webdriver.remote(opts).init()
