Link = require('react-router').Link

module.exports = React.createClass
  displayName: 'Home'

  componentDidMount: ->
    window.scroll(0,0)

  render: ->
    <div>
      <h1>Home</h1>
      <p>Just a dummy homepage. Should include rules and stuff...</p>
    </div>
