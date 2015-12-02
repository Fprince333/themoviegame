require("./style.scss")
CardTitle = require 'material-ui/lib/card/card-title'
CardMedia = require 'material-ui/lib/card/card-media'
_ = require 'underscore'

module.exports = React.createClass
  render: ->
    if not _.isEmpty(@props.movie)
      <CardMedia overlay={<CardTitle title="Name an actor or actress in" subtitle={@props.movie.title + " - " + @props.movie.release_date.substring(0, 4) }/>}><img className="poster-image" src={"http://image.tmdb.org/t/p/w780" + @props.movie.backdrop_path}/></CardMedia>
    else
      <div></div>
