WebSocket = require('ws')
ws = new WebSocket('ws://localhost:8080')
Bacon = require('baconjs')
React = require('react')


messageStream = new Bacon.Bus
ws.onmessage = (frame) ->
  message = JSON.parse frame.data
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

MessagesField = React.createClass
  getInitialState: ->
    text: ''
    
  componentWillMount: ->
    # Bind the component's state to values in the stream.
    @props.stream.onValue(@setState.bind(this))
  
  render: ->
    React.DOM.p(null, [@state.type, @state.id, @state.action].join(' '))

textStream = new Bacon.Bus

labelStream = textStream.map(reverseText)

React.renderComponent(
  React.DOM.div(
    null,
    TextField(stream: textStream),
    Label(stream: labelStream),
    MessagesField(stream: messageStream)
  ),
  document.body
)
