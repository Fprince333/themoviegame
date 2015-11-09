TheMovieGame = require './components/themoviegame/component'

module.exports = React.createClass
  displayName: 'Home'

  componentDidMount: ->
    window.scroll(0,0)

  render: ->
    <div>
      <TheMovieGame />
    </div>
