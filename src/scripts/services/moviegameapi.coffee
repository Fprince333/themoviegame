$ = require 'jquery'

urlForPath = (path) ->
  url = if process.env.NODE_ENV is 'production' then 'http://tmg-api.herokuapp.com' else 'http://localhost:3000'
  url += path
  url

request = (path, type, data, options={}) ->
    url = urlForPath(path)
    $.ajax
      cache: options.cache || false
      type: type
      url: url
      dataType: "json"
      data: data

module.exports =
  get: (path, data, options)    -> request(path, "GET", data, options)
  post: (path, data, options)   -> request(path, "POST", data, options)
  put: (path, data, options)    -> request(path, "PUT", data, options)
  delete: (path, data, options) -> request(path, "DELETE", data, options)

