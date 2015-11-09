require("./style.scss")
_ = require 'underscore'

module.exports = React.createClass
  displayName: 'ActorList',

  render: ->
    if @props.actors.length
      actorList = _.map @props.actors, (actor) ->
        <li key={actor.id}>&#9991 {actor.name}</li>
    else
      actorList = <li>...</li>
    <ul className="stats-container__ul">
      {actorList}
    </ul>
