WebSocket = require 'ws'
Bacon = require 'baconjs'

CommunicationMixin =
  input: new Bacon.Bus
  output: new Bacon.Bus

ws = new WebSocket 'ws://' + window.location.hostname + ':8080'
ws.onmessage = (frame) ->
  message = JSON.parse frame.data
  CommunicationMixin.input.push message
  
CommunicationMixin.output.onValue (e) ->
  ws.send JSON.stringify e
  
module.exports = CommunicationMixin
