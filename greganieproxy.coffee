url = require('url')
select = require('soupselect').select
htmlparser = require("htmlparser")
sys = require('sys')
http = require('http')

server = http.createServer (req, serverResponse) ->
  if req.url is "/"
    gReq = http.request
      hostname: 'www.mywedding.com'
      path: '/stephanieandgregoryinrye/'
      method: 'GET'
      port:80
    , (res) ->
      console.log "started getting response"
      data = ''
      res.on 'data', (chunk) ->
          data += chunk.toString()
          sys.puts 'chin'
      res.on 'end', () ->
          serverResponse.write(data)
          serverResponse.end()
    gReq.end()
  else
    serverResponse.writeHead 302,
      'Location': "http://www.mywedding.com#{req.url}"
    serverResponse.end()

    # gReq = http.request
    #   hostname: 'www.mywedding.com'
    #   path: req.url
    #   method: 'GET'
    #   port:80
    # , (res) ->
    #   serverResponse.setHeader("Content-Type", res.headers['content-type'])
    #   res.on 'data', (chunk) ->
    #     serverResponse.write chunk
    #   res.on 'end', () ->
    #     serverResponse.end()

  #gReq.end()

server.listen(9000)
