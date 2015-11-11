List = require 'material-ui/lib/lists/list'
ListItem = require 'material-ui/lib/lists/list-item'
_ = require 'underscore'


module.exports = React.createClass
  render: ->
    visibility = if @props.visible then "block" else "none"
    if @props.actors.length > 0
      hintList = _.map @props.actors, (actor) ->
        <ListItem key={actor.id} primaryText={actor.name}/>
    else
      hintList = "..."
    <List onClick={@props.onClick} style={display: visibility, width: "256px", margin: "0 auto"}>
      {hintList}
    </List>

