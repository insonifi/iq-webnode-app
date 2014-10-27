# @cjsx React.DOM 
_ = require 'lodash'
React = require 'react'
CommunicationMixin = require '../Communication.coffee'
Camera = require './Camera.coffee'
Bootstrap = require 'react-bootstrap'
Panel = Bootstrap.Panel

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
    
module.exports = CamList
