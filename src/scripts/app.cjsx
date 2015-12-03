Link = require('react-router').Link
RouteHandler = require('react-router').RouteHandler
AppBar = require 'material-ui/lib/app-bar'
IconButton = require 'material-ui/lib/icon-button'
Menu = require 'material-ui/lib/svg-icons/navigation/menu'
Play = require 'material-ui/lib/svg-icons/av/play-arrow'

module.exports = React.createClass
  displayName: "App"
  render: ->
    <div>
      <div className="movie-game-container" style={paddingBottom: "0px"}>
        <AppBar style={backgroundColor: "#f44355"}
          iconElementLeft={<Link to="play"><IconButton><Play/></IconButton></Link>}
          iconElementRight={<Link to="leaderboard"><IconButton><Menu/></IconButton></Link>} />
      </div>
      <RouteHandler/>
    </div>
