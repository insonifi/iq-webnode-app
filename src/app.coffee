# @cjsx React.DOM 
React = require 'react'
_ = require 'lodash'
ActionButton = require './components/ActionButton.coffee'
EventChart = require './components/EventChart.coffee'
CamList = require './components/CamList.coffee'
Log = require './components/Log.coffee'
Map = require './components/Map.coffee'


map_layers =
  [
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

React.renderComponent(
  <div className="container">
    <div className="row">
      <div className="col-md-2">
        <ActionButton type="MACRO" id="1"} action="RUN" />
        <ActionButton msg="React" type="TIMER" id="1"} action="DISABLE" />
        <ActionButton msg="React" type="TIMER" id="1"} action="ENABLE" />
        <ActionButton type="CAM" id="1"} action="ARM" />
        <ActionButton type="CAM" id="1"} action="DISARM" />
      </div>
      <div className="col-md-2">
        <CamList />
      </div>
    </div>
    <div className="row">
      <div className="col-md-8">
        <Map layers={map_layers}/>
      </div>
    </div>
    <div className="row">
      <div className="col-md-5">
        <Log />
      </div>
      <div className="col-md-4">
        <EventChart interval=1 />
      </div>
    </div>
  </div>
  document.body
)
global.React = React
