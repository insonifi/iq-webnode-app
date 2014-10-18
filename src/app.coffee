# @cjsx React.DOM 
WebSocket = require 'ws'
Bacon = require 'baconjs'
React = require 'react'
Lazy = require 'lazy.js'
Bootstrap = require 'react-bootstrap'
ListGroup = Bootstrap.ListGroup
ListGroupItem = Bootstrap.ListGroupItem
Label = Bootstrap.Label
TabbedArea = Bootstrap.TabbedArea
TabPane = Bootstrap.TabPane

queue = []

CommunicationMixin =
  input: new Bacon.Bus
  output: new Bacon.Bus

ws = new WebSocket 'ws://' + window.location.hostname + ':8080'
ws.onmessage = (frame) ->
  message = JSON.parse frame.data
  CommunicationMixin.input.push message
  
CommunicationMixin.output.onValue (e) ->
  ws.send JSON.stringify e
#ws.onopen = -> 
#    #outputStream = new Bacon.Bus
#    CommunicationMixin.output.onValue (e) ->
#      ws.send JSON.stringify e
#    #outputStream.push e for e in queue

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
  mixins: [CommunicationMixin]
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
    @input
    .filter ((e) ->
      e.type + ':' + e.id is 'CAM:' + @props.id
    ).bind @
    .onValue ((e) ->
      if @handlers[e.action] isnt undefined
          @handlers[e.action].call @
      ).bind @
  render: ->
    <Label bsStyle={@state.style} style={left: @props.x, top: @props.y, position: 'relative'}>
      {@props.id}
    </Label>

CamList = React.createClass
  mixins: [CommunicationMixin]
  displayName: 'CamList'
  getInitialState: -> {}
  componentDidMount: ->
    @input
    .filter (e) -> e.type is 'CAM'
    .onValue ((e) ->
      if @state[e.id] is undefined
        @state[e.id] = true
        @setState(@state)
      ).bind @
  render: ->
    keys = Object.keys @state
    <ListGroup className=".col-xs-4">
      {keys.sort().map ((id) ->
        <ListGroupItem key={id}>
          <Camera id={id} />
        </ListGroupItem>
      ).bind @}
    </ListGroup>

MapLayer = React.createClass
  displayName: 'MapLayer'
  getInitialState: -> null
  render: ->
    list = @props.config.list
    <div style={@props.style}>
      {list.map (o) ->
        items[o.type]({key: o.id, id: o.id, x: o.x, y: o.y})}
    </div>
    
Map = React.createClass
  displayName: 'Map'
  getInitialState: ->
    key: 0
    layers: [
      name: 'layer 1'
      style:
        background: 'grey'
      list: [
        type: 'CAM'
        id: 1
        x: 10
        y: 50
      ,
        type: 'CAM'
        id: 2
        x: 30
        y: 80
      ,
        type: 'CAM'
        id: 3
        x: 70
        y: 20
      ]
    ,
      name: 'another layer'
      style:
        background: 'grey'
      list: [
        type: 'CAM'
        id: 3
        x: 40
        y: 20
      ,
        type: 'CAM'
        id: 4
        x: 100
        y: 60
      ]
    ]
  render: ->
    i = 0
    <TabbedArea defaultActiveKey={@state.key}>
      {@state.layers.map ((layer) ->
        <TabPane key={i++} tab={layer.name}>
          <MapLayer config={layer} />
        </TabPane>
      ).bind @}
    </TabbedArea>
      
    
items = 
  CAM: Camera
React.renderComponent(
  <div>
    <div>
      <SendButton />
      <CamList />
    </div>
    <div>
      <Map />
    </div>
  </div>
  document.body
)
global.React = React
