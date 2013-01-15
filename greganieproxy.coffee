url = require('url')
select = require('soupselect').select
htmlparser = require("htmlparser")
sys = require('sys')
http = require('http')

urlCache = {}

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
  console.log "Got #{req.url}"
  if req.url is "/sneakyscripts.js"
    serverResponse.setHeader("Content-Type", "text/javascript")
    serverResponse.write """
    $(function() {
      window.setInterval(cornify_add, 1000);
    });
    """
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
      res.on 'end', () ->
          serverResponse.write injectScriptIntoHead data, [
            "http://www.cornify.com/js/cornify.js"
            "/sneakyscripts.js"
          ]
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
      if isHtml
        console.log "Is HTML, processing.."
        serverResponse.setHeader("Content-Type", res.headers['content-type'])
        res.on 'data', (chunk) ->
          serverResponse.write chunk
        res.on 'end', () ->
          serverResponse.end()
      else
        urlCache[req.url] = true
        console.log "Is not, redirecting..."
        res.destroy() # terminate connection
        sendRedirectToUrl(serverResponse, req.url)

    gReq.end()

server.listen(9000)
