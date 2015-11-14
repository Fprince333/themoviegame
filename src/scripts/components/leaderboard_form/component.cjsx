require("./style.scss")
FormData = require('react-form-data')
$ = require('jquery')
Api = require("../../services/api")
Card = require 'material-ui/lib/card/card'
CardTitle = require 'material-ui/lib/card/card-title'
CardActions = require 'material-ui/lib/card/card-actions'
FlatButton = require 'material-ui/lib/flat-button'
TextField = require 'material-ui/lib/text-field'


module.exports = React.createClass
  displayName: 'LeaderboardForm',
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
    <Card>
      <CardTitle title="Nice Round!" subtitle={"Score: " + @props.score}/>
      <CardActions>
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
