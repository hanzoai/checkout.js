fb = (opts) ->
  unless window._fbq?
    window._fbq = []
    fbds = document.createElement 'script'
    fbds.async = true
    fbds.src = '//connect.facebook.net/en_US/fbds.js'
    s = document.getElementsByTagName('script')[0]
    s.parentNode.insertBefore fbds, s
    _fbq.loaded = true

  window._fbq.push ['track', opts.id,
    value:    opts.value,
    currency: opts.currency,
  ]

ga = (opts) ->
  unless window._gaq?
    window._gaq = []
    ga = document.createElement 'script'
    ga.type = 'text/javascript'
    ga.async = true
    ga.src = ((if 'https:' is document.location.protocol then 'https://' else 'http://')) + 'stats.g.doubleclick.net/dc.js'
    s = document.getElementsByTagName('script')[0]
    s.parentNode.insertBefore ga, s

  window._gaq.push ['_trackEvent', opts.category, opts.name]

module.exports =
  track: (opts = {}) ->
    ga opts.google if opts.google?.category?
    fb opts.facebook if opts.facebook?.id?
