# @cjsx React.DOM 
React = require 'react'
CommunicationMixin = require '../Communication.coffee'
Camera = React.createClass
  mixins: [CommunicationMixin]
  displayName: 'Camera'
  getInitialState: ->
    style: 'label-default'
  handlers:
      'MD_START': -> @setState
        style: 'label-warning'
      'MD_STOP': -> @setState
        style: 'label-success'
      'ARM': -> @setState
        style: 'label-success'
      'DISARM': -> @setState
        style: 'label-default'
  componentDidMount: ->
    @setState
      dispose:
        @input
        .filter ((e) ->
          e.type + ':' + e.id is 'CAM:' + @props.id
        ).bind @
        .onValue ((e) ->
          if @handlers[e.action]?
              @handlers[e.action].call @
          ).bind @
  componentWillUnmount: ->
    @state.dispose()
  render: ->
    styleClass = 'label ' + @state.style
    <span className={styleClass}>{@props.id}</span>
    
module.exports = Camera
