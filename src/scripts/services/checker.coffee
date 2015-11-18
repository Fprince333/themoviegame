moment = require 'moment'
_ = require 'underscore'

disallowedCategories = [10770, 99, 10769, 16, 10751]

module.exports =
  isTooObscure: (popularity) -> if popularity < 0.1 then true else false
  isNotReleased: (date) -> if moment(date).isBefore(moment(), 'day') then false else true
  isTooOld: (date) -> if moment(date).isBefore( moment().year(1975) , 'year') then true else false
  isNotAllowed: (idArray) -> if _.intersection(disallowedCategories, idArray).length > 0 then return true else return false
