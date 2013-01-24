url = require('url')
http = require('http')
fs = require('fs')
cf = require('coffee-script')
path = require('path')

urlCache = {}

SCRIPTS_TO_INJECT = [
  "http://www.cornify.com/js/cornify.js"
  "/scripts/cornify.coffee"
  "/scripts/givemethetweets.coffee"
]

LOCAL_SCRIPTS = [
  'cornify.coffee'
  'givemethetweets.coffee'
]

sendRedirectToUrl = (res, url) ->
  res.writeHead 302,
    'Location': "http://www.mywedding.com#{url}"
  res.end()

injectScriptIntoHead = (html, scriptUrls = []) ->
  scriptTags = []
  for url in scriptUrls
    scriptTags.push """
    <script type="text/javascript" src="#{url}"></script>
    """

  scriptText = scriptTags.join("")
  html.replace(/(<\/head[^>]*>)/, "\n#{scriptText}$1")

server = http.createServer (req, serverResponse) ->

  # serve local coffeescript directly
  if req.url.split("/")[2] in LOCAL_SCRIPTS
    scriptname = req.url.split("/")[2]

    filename = path.join(__dirname, "scripts", scriptname)
    console.log "Serving #{filename} directly"
    fs.readFile filename, "utf8", (err, data) ->
      serverResponse.setHeader("Content-Type", "text/javascript")
      serverResponse.write cf.compile(data)
      serverResponse.end()
    return

  if req.url is "/"
    gReq = http.request
      hostname: 'www.mywedding.com'
      path: '/stephanieandgregoryinrye/'
      method: 'GET'
      port:80
    , (res) ->
      data = ''
      res.on 'data', (chunk) ->
          data += chunk.toString()
      res.on 'error', ->
        serverResponse.end()
      res.on 'end', () ->
          serverResponse.write injectScriptIntoHead data, SCRIPTS_TO_INJECT
          serverResponse.end()
    gReq.end()
  else
    if urlCache[req.url]
      sendRedirectToUrl serverResponse, req.url
      return

    gReq = http.request
      hostname: 'www.mywedding.com'
      path: req.url
      method: 'GET'
      port: 80
    , (res) ->
      headers = res.headers
      isHtml = headers['content-type'] and headers['content-type'].match('text/html')
      if not isHtml
        urlCache[req.url] = true #don't hit it again

      console.log "#{req.url} to #{req.connection.remoteAddress}"
      serverResponse.setHeader("Content-Type", res.headers['content-type'])
      res.on 'data', (chunk) ->
        serverResponse.write chunk
      res.on 'error', ->
        serverResponse.end()
      res.on 'end', () ->
        serverResponse.end()

    gReq.end()

server.on 'error', (e) ->
  console.log "Got error #{e}"

server.listen(9000)
