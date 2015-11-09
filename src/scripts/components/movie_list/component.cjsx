require("./style.scss")
_ = require 'underscore'

module.exports = React.createClass
  displayName: 'MovieList',

  render: ->
    movieList = _.map @props.movies, (movie) ->
      <li key={movie.id}>&#9991 {movie.title}</li>
    <ul className="stats-container__ul">
      {movieList}
    </ul>
