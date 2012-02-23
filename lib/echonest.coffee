_ = require 'underscore'
fermata = require 'fermata'
querystring = require 'querystring'

echonest_api = require './echonest_api'

module.exports = echonest = {}

class echonest.Echonest
  constructor: (options = {}) ->
    _.defaults options, {
      api_key: 'QQKP1N3XKJO7YTSRS'
      api_version: 'v4'
      host: 'http://developer.echonest.com'
    }
    _.extend @, options

    @jsonclient = fermata.json(@host)['api'][@api_version](api_key: @api_key)
    api = echonest_api[@api_version]
    for endpoint, httpmethod of api
      # echonest is always just /type/method
      [type, method] = endpoint.split('/')
      @[type] ?= {}
      @[type][method] ?= do (endpoint, httpmethod) =>
        (query, callback) =>
          @request(endpoint, query, callback, httpmethod)

  defaultCallback: (err, data) ->
    console.log 'err: ', err
    console.log 'data: ', data

  request: (endpoint, query, callback, method = 'get') ->
    # callback is called with (err, data)
    client = @jsonclient([endpoint])
    if method == 'get'
      client = client(query)
    # console.log client() # to show url
    wrapper = (err, result) =>
      callback ?= @defaultCallback
      # pluck response
      if result?.response?
        result = result.response
      callback err, result
    switch method
      when 'get' then client.get(wrapper)
      when 'post' then client.post(
        {'Content-Type': "multipart/form-data"}, query, wrapper)
