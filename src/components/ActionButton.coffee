# @cjsx React.DOM 
React = require 'react'
CommunicationMixin = require '../Communication.coffee'
Bootstrap = require 'react-bootstrap'
Button = Bootstrap.Button

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
    
module.exports = ActionButton
