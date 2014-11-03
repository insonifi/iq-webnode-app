# @cjsx React.DOM 
_ = require 'lodash'
React = require 'react'
Camera = require './Camera.coffee'

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
    layers = @props.layers
    active: if layers.length isnt 0 then layers[0].name else ''
  handleClick: (e) ->
    @setState
      active: e.target.text
  render: ->
    layers = @props.layers
    active = @state.active
    i = 0
    <div>
      <ol className="nav nav-tabs">
        {_(layers).map(((layer) ->
          styleClass = if active is layer.name then 'active' else ''
          <li key={i++} className={styleClass}><a href="#" onClick={@handleClick}>{layer.name}</a></li>
        ).bind(@)).value()}
      </ol>
      {_(layers).where({name: active}).map (layer)->
          <MapLayer width={layer.width} height={layer.height} list={layer.list} image={layer.image}/>      
      }
    </div>
  
module.exports = Map
