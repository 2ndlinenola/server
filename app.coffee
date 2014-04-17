express = require "express"

app = express()

app.use express.bodyParser()

app.post "*", (req, res) ->
  console.log "got request!"
  console.log req.body
  res.end "Thanks brah!"

port = Number(process.env.PORT || 5000)
app.listen port, ->
  console.log "here we go!"
