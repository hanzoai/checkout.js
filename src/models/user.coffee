# User contains 3 pieces of data:
#
# 1) email
# 2) user first name
# 3) user last name
#

module.exports = class User
  constructor: (@email='', @firstName='', @lastName='')->
