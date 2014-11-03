# @cjsx React.DOM 
React = require 'react'
CommunicationMixin = require '../Communication.coffee'
_ = require 'lodash'

Log = React.createClass
  mixins: [CommunicationMixin]
  displayName: 'Log'
  getInitialState: -> 
    log: []
  componentDidMount: ->
    @input
    .onValue ((e) ->
      @state.log.push e
      @setState
        log: @state.log.slice -5
    ).bind @
  render: ->
    log = @state.log
    k = 0
    <div className="panel panel-primary">
      <div className="panel-heading">Event log</div>
      <ul className="list-group">
        {_(log).map((i) ->
            <li className="list-group-item" key={k++}>
              <span className="badge">{i.params.time}</span> {i.type} {i.id} {i.action}
            </li>
        ).value()}
      </ul>
    </div>

module.exports = Log
