TheMovieGame = require './components/themoviegame/component'

module.exports = React.createClass
  displayName: 'Play'

  componentDidMount: ->
    window.scroll(0,0)

  render: ->
    <div>
      <TheMovieGame />
    </div>
