# @cjsx React.DOM 
WebSocket = require 'ws'
Bacon = require 'baconjs'
React = require 'react'
Bootstrap = require 'react-bootstrap'
ListGroup = Bootstrap.ListGroup
ListGroupItem = Bootstrap.ListGroupItem
Label = Bootstrap.Label

inputStream = new Bacon.Bus
outputStream = new Bacon.Bus
queue = []

ws = new WebSocket 'ws://' + window.location.hostname + ':8080'
ws.onmessage = (frame) ->
  message = JSON.parse frame.data
  inputStream.push message
  
outputStream.onValue (e) ->
  queue.push(e)
  console.log('queued', e)
    
ws.onopen = -> 
    outputStream = new Bacon.Bus
    outputStream.onValue (e) ->
      ws.send JSON.stringify e
    outputStream.push e for e in queue

SendButton = React.createClass  
  handleClick: ->
    outputStream.push
      type: 'CORE'
      id: ''
      action: 'GET_CONFIG'
      params:
        objtype: 'CAM'
        objid: ''
  render: ->
    <button onClick={@handleClick}>MACRO RUN</button>
###
objectFactory = (config) ->
  React.createClass
    getInitialState: ->
      state: 
        alarm: false
      style: 'success'
    componentWillMount: ->
      @props.stream
      .onValue ((e) ->
        if config.handlers[e.action] isnt undefined
            config.handlers[e.action].call @
        ).bind @
    render: ->
      Bootstrap.Label(
        bsStyle: @state.style,
        [config.type, config.id].join ' '
      )
###
MessagesField = React.createClass
  getInitialState: ->
    text: ''
  componentWillMount: ->
    @props.stream.onValue @setState.bind @
  render: ->
    React.DOM.p null, [@state.type, @state.id, @state.action].join(' ')

###
Camera = (id, stream) ->
  objectFactory
    type: 'CAM'
    id: id
    stream: stream
    handlers:
      'MD_START': -> @setState
        style: 'warning'
      'MD_STOP': -> @setState
        style: 'success'
###
Camera = React.createClass
  displayName: 'Camera'
  getInitialState: ->
    style: 'default'
  handlers:
      'MD_START': -> @setState
        style: 'warning'
      'MD_STOP': -> @setState
        style: 'success'
      'ARM': -> @setState
        style: 'success'
      'DISARM': -> @setState
        style: 'default'
  componentDidMount: ->
    @props.stream
    .onValue ((e) ->
      if @handlers[e.action] isnt undefined
          @handlers[e.action].call @
      ).bind @
  render: ->
    <Label bsStyle={@state.style}>{@props.id}</Label>

CamList = React.createClass
  displayName: 'CamList'
  getInitialState: -> {}
  componentDidMount: ->
    @props.stream
    .onValue ((e) ->
      if @state[e.id] is undefined
        @state[e.id] = true
        @setState(@state)
    ).bind @
  render: ->
    keys = Object.keys @state
    <ListGroup>
      {keys.sort().map ((id) ->
        <ListGroupItem key={id} xs={3}>
          <Camera id={id} stream={@props.stream.filter (e) -> e.id is id} />
        </ListGroupItem>
      ).bind @}
    </ListGroup>

Map = React.createClass
  displayName: 'Map'
  getInitialState: ->
    'layer 1': []
    'another layer': []
  render: ->
    <div>wtf</div>
    
React.renderComponent(
  <div>
    <MessagesField stream={inputStream} />
    <SendButton />
    <CamList stream={inputStream.filter (e) -> e.type is 'CAM'} />
  </div>
  document.body
)
global.React = React
