# @cjsx React.DOM 
_ = require 'lodash'
React = require 'react'
Camera = require './Camera.coffee'
Bootstrap = require 'react-bootstrap'
Panel = Bootstrap.Panel
TabbedArea = Bootstrap.TabbedArea
TabPane = Bootstrap.TabPane

items = 
  CAM: Camera

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
  getDefaultProps: ->
    layers: []
  getInitialState: ->
    key: 0
  render: ->
    layers = @props.layers
    i = 0
    <TabbedArea defaultActiveKey={@state.key}>
      {_(layers).map((layer) ->
        <TabPane key={i++} tab={layer.name}>
          <MapLayer width={layer.width} height={layer.height} list={layer.list} image={layer.image}/>
        </TabPane>
      ).value()}
    </TabbedArea>
  
module.exports = Map
