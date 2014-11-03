# @cjsx React.DOM 
React = require 'react'
CommunicationMixin = require '../Communication.coffee'

ActionButton = React.createClass  
  mixins: [CommunicationMixin]
  handleClick: ->
    @output.push
      msg: @props.msg || "Event"
      type: @props.type
      id: @props.id
      action: @props.action
  render: ->
    <button className="btn btn-default" onClick={@handleClick}>{@props.type} {@props.id} {@props.action}</button>
    
module.exports = ActionButton
