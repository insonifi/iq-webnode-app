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
          <Camera key={id} id={id} />
      ).value()}
    </Panel>

MapLayer = React.createClass
  displayName: 'MapLayer'
  getInitialState: ->
    limit: 5
    ratio: 1
    step: 0.03
    imgX: 0
    imgY: 0
    offsetX: 0
    offsetY: 0

  getDefaultProps: ->
    width: '800'
    height: '600'
    image: ''
    list: []
  bound: (val, low, high) ->
    if val < low then val = low
    if val > high then val = high
    val
  
  handleWheel: (e) ->
    if e.target.nodeName isnt 'IMG' then return
    e.stopPropagation()
    e.preventDefault()
    $targetOffset = $(e.target).offset() 
    x = (e.pageX - $targetOffset.left) / @state.ratio
    y = (e.pageY - $targetOffset.top) / @state.ratio
    newratio = @bound (@state.ratio + @state.step * Math.sign(e.deltaY)), 1, @state.limit
    @setState
      ratio: newratio
      imgX: x * (1 - newratio)
      imgY: y * (1 - newratio)
  handleDragStart: (e) ->
    e.preventDefault()
    @setState
      dragX: e.clientX
      dragY: e.clientY
      drag: true
  handleDragStop: (e) -> @setState
    dragX: 0
    dragY: 0
    drag: false
  handleDrag: (e) ->
    if e.target.nodeName isnt 'IMG' then return
    e.preventDefault()
    if @state.drag 
      $targetOffset = $(e.target).offset() 
      @setState
        dragX: e.clientX
        dragY: e.clientY
        offsetX: @state.offsetX - (@state.dragX - e.clientX)
        offsetY: @state.offsetY - (@state.dragY - e.clientY)
  render: ->
    ratio = @state.ratio
    ix = @state.imgX + @state.offsetX
    iy = @state.imgY + @state.offsetY
    divstyle =
      width: @props.width
      height: @props.height
      overflow: 'hidden'
      position: 'relative'
    imgstyle =
      position: 'absolute'
      left: ix
      top: iy
      width: ratio * @props.width
      #height: ratio * @props.height

    list = @props.list
    
    <div style={divstyle} onWheel={@handleWheel}>
      <img src={@props.image} style={imgstyle}
        onMouseMove={@handleDrag}
        onMouseDown={@handleDragStart}
        onMouseUp={@handleDragStop}
        onMouseOut={@handleDragStop}
      />
      {_(list).map((o) ->
        <div key={o.id} style={left: ix + o.x * ratio, top: iy + o.y * ratio, zIndex: 2, position: 'absolute'}>
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
      image: 'img/exterior.jpg'

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
      image: 'img/plan.jpg'

      list: [
        type: 'CAM'
        id: 3
        x: 345
        y: 345
      ,
        type: 'CAM'
        id: 4
        x: 335
        y: 180
      ]
    ,
      name: 'SVG (vector) layer'
      image: 'img/idealhouseplan2.svg'
      list: [
        type: 'CAM'
        id: 1
        x: 160
        y: 45
      ,
        type: 'CAM'
        id: 2
        x: 300
        y: 250
      ]
    ]
  render: ->
    layers = @state.layers
    i = 0
    <TabbedArea defaultActiveKey={@state.key}>
      {_(layers).map((layer) ->
        <TabPane key={i++} tab={layer.name}>
          <MapLayer width={layer.width} height={layer.height} list={layer.list} image={layer.image}/>
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

Chart = React.createClass
  render: ->
    <svg width={@props.width} height={@props.height}>{@props.children}</svg>
    
Line = React.createClass
  getDefaultProps: ->
    path: ''
    color: 'blue'
    width: 2
    
  render: ->
    <path d={@props.path} stroke={@props.color} strokeWidth={@props.width} fill="none" />

DataSeries = React.createClass
  getDefaultProps: ->
    title: ''
    data: []
    interpolate: 'linear'
  
  render: ->
    yScale = @props.yScale
    xScale = @props.xScale
    
    path = d3.svg.line()
      .x (d) -> xScale(d.x)
      .y (d) -> yScale(d.y)
      .interpolate @props.interpolate
    
    <Line path={path @props.data} color={@props.color} />
    
LineChart = React.createClass
  mixins: [CommunicationMixin]
  getDefaultProps: ->
    width: 300
    height: 300
  getInitialState: ->
    series: [],
    moment:
      x: 0
      y: 0
    timer: null
  
  componentWillMount: ->
    @setState 
      timer: setInterval ((->
        series = @state.series
        series.unshift @state.moment
        @setState
          series: series.slice 0,30
          moment:
            x: @state.moment.x + 1
            y: 0
      ).bind @)
      , @props.interval * 1000 #milliseconds
        
  componentDidMount: ->
    @input
    .filter (e) -> e.type is 'CAM'
    .onValue ((e) ->
      m = @state.moment
      if e.action is 'MD_START'
        m.y += 1
      if e.action is 'MD_STOP'
        m.y -= 1
      @setState
        moment: m
    ).bind @
  
  render: ->
    data = @props.data
    size =
      width: @props.width
      height: @props.height
      
    xValues = _.chain(@state.series).pluck('x').value()
    yValues = _.chain(@state.series).pluck('y').value()
    
    xScale = d3.scale.linear()
    .domain [_(xValues).min(), _(xValues).max()]
    .range [@props.width, 0]
    
    yScale = d3.scale.linear()
    .domain [_(yValues).min(), _(yValues).max()]
    .range [@props.height, 0]

    <Chart width={@props.width} height={@props.height}>
      <DataSeries data={@state.series} size={size} xScale={xScale} yScale={yScale} ref="series1" color="cornflowerblue" />
    </Chart>

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
    </Row>
    <Row>
      <Col md={8}>
        <Map />
      </Col>
    </Row>
    <Row>
      <Col md={5}>
        <Log />
      </Col>
      <Col>
        <LineChart interval=1 />
      </Col>
    </Row>
  </Grid>
  document.body
)
global.React = React
