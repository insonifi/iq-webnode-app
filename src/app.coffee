WebSocket = require 'ws'
ws = new WebSocket 'ws://' + window.location.hostname + ':8080'
Bacon = require 'baconjs'
React = require 'react'
Bootstrap = require 'react-bootstrap'


messageStream = new Bacon.Bus
ws.onmessage = (frame) ->
  message = JSON.parse frame.data
  console.log message
  messageStream.push message

messageStream = new Bacon.Bus

reverse = (s) -> s.split('').reverse().join('')

reverseText = (object) ->
  object.text = reverse(object.text)
  object

TextField = React.createClass
  getInitialState: ->
    text: ''
  
  handleChange: (text) ->
    # Set the component's state and publish it to the stream.
    @setState({text}, -> @props.stream.push(@state))
  
  render: ->
    valueLink = {value: @state.text, requestChange: @handleChange}
    React.DOM.input(
      type: 'text',
      placeholder: 'Enter some text',
      valueLink: valueLink
    )

Label = React.createClass
  getInitialState: ->
    text: ''
    
  componentWillMount: ->
    # Bind the component's state to values in the stream.
    @props.stream.onValue(@setState.bind(this))
  
  render: ->
    React.DOM.p(null, @state.text)

SendButton = React.createClass  
  handleClick: ->
    ws.send JSON.stringify
      type: 'CORE'
      id: ''
      action: 'GET_CONFIG'
      params:
        objtype: 'MAPLAYER'
        objid: '1'
  render: ->
    React.DOM.button(
      onClick: @handleClick,
      'MACRO RUN'
    )

objectFactory = (config) ->
  React.createClass
    getInitialState: ->
      #type: config.type
      #id: config.id
      state: 
        alarm: false
      style: 'success'
    componentWillMount: ->
      @props.stream
      .filter ((e) -> 
        console.log e
        e.type is config.type and e.id is config.id
      ).bind @
      .onValue ((e) ->
        if config.handlers[e.action] isnt undefined
            config.handlers[e.action].call @
        ).bind(@)
    render: ->
      Bootstrap.Label(
        bsStyle: @state.style,
        [config.type, config.id].join ' '
      )

MessagesField = React.createClass
  getInitialState: ->
    text: ''
    
  componentWillMount: ->
    # Bind the component's state to values in the stream.
    @props.stream.onValue(@setState.bind(this))
  
  render: ->
    React.DOM.p(null, [@state.type, @state.id, @state.action].join(' '))

textStream = new Bacon.Bus

Camera = objectFactory
  type: 'CAM'
  id: '1'
  handlers:
    'MD_START': -> @setState
      style: 'warning'
    'MD_STOP': -> @setState
      style: 'success'
      
labelStream = textStream.map(reverseText)

React.renderComponent(
  React.DOM.div(
    null,
    TextField(stream: textStream),
    Label(stream: labelStream),
    MessagesField(stream: messageStream),
    SendButton(),
    Camera(stream: messageStream)
  ),
  document.body
)

global.React = React
