CardTitle = require 'material-ui/lib/card/card-title'
CardMedia = require 'material-ui/lib/card/card-media'

module.exports = React.createClass
  render: ->
    if @props.hasPoster
      <CardMedia overlay={<CardTitle title="Name an actor or actress in" subtitle={@props.movie.title}/>}><img src={"http://image.tmdb.org/t/p/w780" + @props.movie.backdrop_path}/></CardMedia>
    else
      <CardTitle title="Name an actor or actress in" subtitle={@props.movie.title}/>
