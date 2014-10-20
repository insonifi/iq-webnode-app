# @cjsx React.DOM 
WebSocket = require 'ws'
Bacon = require 'baconjs'
React = require 'react'
Bootstrap = require 'react-bootstrap'
_ = require 'lodash'
ListGroupItem = Bootstrap.ListGroupItem
ButtonToolbar = Bootstrap.ButtonToolbar
TabbedArea = Bootstrap.TabbedArea
ListGroup = Bootstrap.ListGroup
TabPane = Bootstrap.TabPane
Button = Bootstrap.Button
Panel = Bootstrap.Panel
Label = Bootstrap.Label
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

ActionButton = React.createClass  
  mixins: [CommunicationMixin]
  handleClick: ->
    @output.push
      msg: @props.msg || "Event"
      type: @props.type
      id: @props.id
      action: @props.action
  render: ->
    <Button onClick={@handleClick}>{@props.type} {@props.id} {@props.action}</Button>
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
    <Label bsStyle={@state.style}>
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
    <Panel header="Camera states">
      {_(keys).sort().map((id) ->
          <Camera id={id} />
      ).value()}
    </Panel>

MapLayer = React.createClass
  displayName: 'MapLayer'
  getInitialState: -> null
  render: ->
    list = @props.config.list
    <div style={@props.config.style}>
      {_(list).map((o) ->
        <div key={o.id} style={left: o.x, top: o.y, position: 'relative'}>
          {items[o.type]({key: o.id, id: o.id})}
        </div>
      ).value()}
    </div>
    
Map = React.createClass
  displayName: 'Map'
  getInitialState: ->
    key: 0
    layers: [
      name: 'layer 1'
      style:
        background: 'url(img/exterior.jpg)'
        'background-size': 'cover'
        width: 800
        height: 600
      list: [
        type: 'CAM'
        id: 1
        x: 630
        y: 320
      ,
        type: 'CAM'
        id: 2
        x: 360
        y: 390
      ,
        type: 'CAM'
        id: 3
        x: 430
        y: 210
      ]
    ,
      name: 'another layer'
      style:
        background: 'url(img/plan.jpg)'
        'background-size': 'cover'
        width: 800
        height: 600
      list: [
        type: 'CAM'
        id: 3
        x: 615
        y: 370
      ,
        type: 'CAM'
        id: 4
        x: 450
        y: 60
      ]
    ]
  render: ->
    layers = @state.layers
    i = 0
    <TabbedArea defaultActiveKey={@state.key}>
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
    <Panel header="Event log" bsStyle="info">
      <ListGroup>
        {_(log).map((i) ->
            <ListGroupItem key={k++}>
              <Label>{i.params.time}</Label> {i.type} {i.id} {i.action}
            </ListGroupItem>
        ).value()}
      </ListGroup>
    </Panel>

items = 
  CAM: Camera
  
React.renderComponent(
  <Grid>
    <Row>
      <Col md={2}>
        <ActionButton type="MACRO" id="1"} action="RUN" />
        <ActionButton msg="React" type="TIMER" id="1"} action="DISABLE" />
        <ActionButton msg="React" type="TIMER" id="1"} action="ENABLE" />
        <ActionButton type="CAM" id="1"} action="ARM" />
        <ActionButton type="CAM" id="1"} action="DISARM" />
      </Col>
      <Col md={2}>
        <CamList />
      </Col>
      <Col md={4}>
        <Log />
      </Col>
    </Row>
    <Row>
      <Col md={8}>
        <Map />
      </Col>
    </Row>
  </Grid>
  document.body
)
global.React = React
