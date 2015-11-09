Link = require('react-router').Link
RouteHandler = require('react-router').RouteHandler
Header = require('./components/header/component')

module.exports = React.createClass
  displayName: "Header"
  render: ->
    <div>
      <Header>
        <div>
          <Link to="home">Home</Link>
        </div>
        <div>
          <Link to="play">Play</Link>
        </div>
        <div>
          <Link to="leaderboard">Leaderboard</Link>
        </div>
      </Header>
      <RouteHandler/>
    </div>
