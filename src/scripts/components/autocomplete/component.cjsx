List = require 'material-ui/lib/lists/list'
ListItem = require 'material-ui/lib/lists/list-item'
Avatar = require 'material-ui/lib/avatar'
_ = require 'underscore'


module.exports = React.createClass
  render: ->
    visibility = if @props.visible then "block" else "none"
    if @props.actors.length > 0
      hintList = _.map @props.actors, (actor) ->
        if actor.profile_path is null
          <ListItem key={actor.id} primaryText={actor.name} leftAvatar={<Avatar color="#bdbdbd", backgroundColor="#f44355">{actor.name.substring(1, 0)}</Avatar>}/>
        else
          <ListItem key={actor.id} primaryText={actor.name} leftAvatar={<Avatar src={"http://image.tmdb.org/t/p/w92" + actor.profile_path} />}/>
    else
      hintList = "..."
    <List onClick={@props.onClick} style={display: visibility, width: "256px", margin: "0 auto"}>
      {hintList}
    </List>

