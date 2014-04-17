_       = require "underscore"
express = require "express"
http    = require "http"
socket  = require "socket.io"

app    = express()
server = http.createServer app
io     = socket.listen server
io.set "transports", ["xhr-polling"]

app.use express.bodyParser()
app.use express.static(__dirname + "/public")

# Sockets code

sockets = []
latestPositionTime = new Date
latestPosition     = null
latestTimeout      = 10*60*1000 # 10 minutes

io.sockets.on "connection", (socket) ->
  sockets.push socket

  socket.on "disconnect", ->
    sockets = _.without sockets, socket

  if latestPosition? && (new Date - latestPositionTime).getTime() > latestTimeout
    latestPosition = null

  return unless latestPosition?
  socket.emit "position", latestPosition

sendPosition = (position) ->
  timestamp = new Date(position.timestamp || position.recorded_at)
  return if latestPosition && timestamp < latestPositionTime
  latestPositionTime = timestamp
  latestPosition     = position

  _.each sockets, (socket) ->
    socket.emit "position", position

app.post "/report.json", (req, res) ->
  console.log "got request!"
  console.log req.body
  _.defer sendPosition, req.body.location
  res.end "Thanks brah!"

port = Number(process.env.PORT || 5000)
server.listen port, ->
    console.log "here we go!"
