# @cjsx React.DOM 
WebSocket = require 'ws'
Bacon = require 'baconjs'
React = require 'react'
Bootstrap = require 'react-bootstrap'
_ = require 'lodash'
ListGroup = Bootstrap.ListGroup
ListGroupItem = Bootstrap.ListGroupItem
Label = Bootstrap.Label
TabbedArea = Bootstrap.TabbedArea
TabPane = Bootstrap.TabPane
Button = Bootstrap.Button
Panel = Bootstrap.Panel
Grid = Bootstrap.Grid
Well = Bootstrap.Well
Row = Bootstrap.Row
Col = Bootstrap.Col

CommunicationMixin =
  input: new Bacon.Bus
  output: new Bacon.Bus

ws = new WebSocket 'ws://' + window.location.hostname + ':8080'
ws.onmessage = (frame) ->
  message = JSON.parse frame.data
  CommunicationMixin.input.push message
  
CommunicationMixin.output.onValue (e) ->
  ws.send JSON.stringify e

SendButton = React.createClass  
  mixins: [CommunicationMixin]
  handleClick: ->
    @output.push
      type: 'MACRO'
      id: '1'
      action: 'RUN'
  render: ->
    <Button onClick={@handleClick}>MACRO 1</Button>
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
    <div style={left: @props.x, top: @props.y, position: 'relative'}>
      <Label bsStyle={@state.style}>
        {@props.id}
      </Label>
    </div>

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
    <Panel className="col-xs-1">
      <ListGroup>
        {_(keys).sort().map((id) ->
          <ListGroupItem key={id}>
            <Camera id={id} />
          </ListGroupItem>
        ).value()}
      </ListGroup>
    </Panel>

MapLayer = React.createClass
  displayName: 'MapLayer'
  getInitialState: -> null
  render: ->
    list = @props.config.list
    <div>
      {_(list).map((o) ->
        items[o.type]({key: o.id, id: o.id, x: o.x, y: o.y})
      ).value()}
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
    layers = @state.layers
    i = 0
    <TabbedArea defaultActiveKey={@state.key} className={"row"}>
      {_(layers).map((layer) ->
        <TabPane key={i++} tab={layer.name}>
          <MapLayer config={layer} />
        </TabPane>
      ).value()}
    </TabbedArea>

Log = React.createClass
  mixins: [CommunicationMixin]
  displayName: 'Log'
  getInitialState: -> 
    log: []
  componentDidMount: ->
    @input
    .onValue ((e) ->
      @state.log.push e
      @setState
        log: @state.log.slice -5
    ).bind @
  render: ->
    log = @state.log
    k = 0
    <Panel className={"col-md-4"}>
      <ListGroup>
        {_(log).map((i) ->
            <ListGroupItem key={k++}>
              <Label>{i.type}</Label>{i.id} {i.action}
            </ListGroupItem>
        ).value()}
      </ListGroup>
    </Panel>

items = 
  CAM: Camera
  
React.renderComponent(
  <Grid>
    <Row>
      <SendButton />
      <CamList />
      <Log />
    </Row>
    <Row>
      <Map />
    </Row>
  </Grid>
  document.body
)
global.React = React
