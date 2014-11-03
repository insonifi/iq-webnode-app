# @cjsx React.DOM 
_ = require 'lodash'
#d3js = require 'd3'
React = require 'react'
CommunicationMixin = require '../Communication.coffee'

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
    
EventChart = React.createClass
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
          series: series.slice 0, 100
          moment:
            x: @state.moment.x + 1
            y: 0
      ).bind @)
      , @props.interval * 333 #milliseconds
        
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
    
module.exports = EventChart
