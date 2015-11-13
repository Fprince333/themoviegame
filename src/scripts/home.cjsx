Link = require('react-router').Link
Paper = require 'material-ui/lib/paper'

module.exports = React.createClass
  displayName: 'Home'

  componentDidMount: ->
    window.scroll(0,0)

  render: ->
    <div className="movie-game-container">
      <Paper zDepth={1}>
        <h1>Welcome to The Movie Game</h1>
        <h2>How To Play</h2>
        <p>Name an actor or actress in the movie suggested</p>
        <p>If the actor or actress was in the movie,</p>
        <p>The computer will pick another movie that actor or actress was in.</p>
        <p>Then you have to name another actor or actress in <em>that</em> movie.</p>
        <p>The game continues until you're stumped.</p>
        <p>If you get far enough, save your score!</p>
        <p>Enjoy.</p>
      </Paper>
    </div>
