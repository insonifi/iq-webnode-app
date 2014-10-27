# @cjsx React.DOM 
React = require 'react'
CommunicationMixin = require '../Communication.coffee'
Bootstrap = require 'react-bootstrap'
Label = Bootstrap.Label

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
    
module.exports = Camera
