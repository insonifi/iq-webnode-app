# @cjsx React.DOM 
_ = require 'lodash'
React = require 'react'
CommunicationMixin = require '../Communication.coffee'
Camera = require './Camera.coffee'

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
    <div className="panel panel-primary">
      <div className="panel-heading">Camera states</div>
      <div className="panel-body">
        {_(keys).sort().map((id) ->
            <Camera key={id} id={id} />
        ).value()}
      </div>
    </div>
    
module.exports = CamList
