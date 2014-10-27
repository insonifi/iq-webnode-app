# @cjsx React.DOM 
React = require 'react'
CommunicationMixin = require '../Communication.coffee'
Bootstrap = require 'react-bootstrap'
_ = require 'lodash'
ListGroupItem = Bootstrap.ListGroupItem
ListGroup = Bootstrap.ListGroup
Panel = Bootstrap.Panel
Label = Bootstrap.Label

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
    <Panel header="Event log" bsStyle="info">
      <ListGroup>
        {_(log).map((i) ->
            <ListGroupItem key={k++}>
              <Label>{i.params.time}</Label> {i.type} {i.id} {i.action}
            </ListGroupItem>
        ).value()}
      </ListGroup>
    </Panel>

module.exports = Log
