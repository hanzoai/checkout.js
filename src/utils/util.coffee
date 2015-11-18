util =
  isObject: (obj) ->
    type = typeof obj
    return type == 'function' || type == 'object' && !!obj

  isNumber: (obj) ->
    return toString.call(obj) == '[object Number]'

module.exports = util

