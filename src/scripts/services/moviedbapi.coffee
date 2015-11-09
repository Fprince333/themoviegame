$ = require 'jquery'

API_KEY = 'api_key=5c9b27cf0af6b9ed8b5204fa273c43ff'

urlForPath = (path) ->
  url = 'http://api.themoviedb.org/3'
  url += path + API_KEY
  url

request = (path, type, data) ->
    url = urlForPath(path)
    $.ajax
      type: type
      url: url
      dataType: "jsonp"
      contentType: 'application/json'
      data: data

module.exports =
  get: (path, data, options)    -> request(path, "GET", data, options)
