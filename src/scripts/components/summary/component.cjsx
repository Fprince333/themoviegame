require("./style.scss")
FormData = require('react-form-data')
$ = require('jquery')
_ = require 'underscore'
Api = require("../../services/api")
Card = require 'material-ui/lib/card/card'
CardTitle = require 'material-ui/lib/card/card-title'
CardActions = require 'material-ui/lib/card/card-actions'
FlatButton = require 'material-ui/lib/flat-button'
TextField = require 'material-ui/lib/text-field'
List = require 'material-ui/lib/lists/list'
ListItem = require 'material-ui/lib/lists/list-item'
ListDivider = require 'material-ui/lib/lists/list-divider'

module.exports = React.createClass
  displayName: 'Summary',
  mixins: [ FormData ],

  getInitialFormData: ->
    {
      'entry[score]': @props.score
    }

  handleSkip: ->
    @props.visibility(false)

  handleSubmit: (e) ->
    e.preventDefault()
    prom = Api.savePlayerScore(@formData)
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log("handle error " + err)
    prom.then (res) =>
      console.log res.status
      @props.visibility(false)
  render: ->
    leftStyles = {
      float: "left",
      width: "45%",
      margin: "10px auto"
    }
    rightStyles = {
      float: "right",
      width: "45%",
      margin: "10px auto"
    }
    movieList = _.map @props.movies, (movie) ->
      <ListItem key={movie.id} primaryText={movie.title}/>
    actorList = _.map @props.actors, (actor) ->
      <ListItem key={actor.id} primaryText={actor.name}/>
    <Card>
      <CardTitle title="Nice Round!" subtitle={"Score: " + @props.score}/>
      <List subheader="Used Movies" style={leftStyles}>
        {movieList}
      </List>
      <ListDivider inset={true} />
      <List subheader="Used Actors" style={rightStyles}>
        {actorList}
      </List>
      <CardActions className="clear">
        <form onChange={@.updateFormData} onSubmit={@handleSubmit}>
          <TextField required={true} hintText="Enter Name" name='entry[name]' underlineFocusStyle={{borderColor: "#f44355"}} hintStyle={{color: '#f44355'}}/>
          <br/>
          <FlatButton primary={true} onClick={@handleSkip} label="Skip">
          </FlatButton>
          <FlatButton secondary={true} label="Save to Leaderboard">
            <input className="hidden-input" type="submit" />
          </FlatButton>
        </form>
      </CardActions>
    </Card>
