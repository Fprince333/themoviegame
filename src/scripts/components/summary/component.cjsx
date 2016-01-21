require("./style.scss")
FormData = require('react-form-data')
$ = require('jquery')
_ = require 'underscore'
Api = require("../../services/api")
Card = require 'material-ui/lib/card/card'
CardTitle = require 'material-ui/lib/card/card-title'
CardActions = require 'material-ui/lib/card/card-actions'
CardText = require 'material-ui/lib/card/card-text'
FlatButton = require 'material-ui/lib/flat-button'
TextField = require 'material-ui/lib/text-field'
GridList = require 'material-ui/lib/grid-list/grid-list'
GridTile = require 'material-ui/lib/grid-list/grid-tile'


module.exports = React.createClass
  displayName: 'Summary',
  mixins: [ FormData ],

  getInitialFormData: ->
    {
      'entry[score]': @props.score
    }

  handleSkip: ->
    @props.visibility(false)

  showForm: ->
    if @props.score > 5 then false else true

  showButton: ->
    if @props.score > 5 then true else false

  formIsValid: (e) ->
    entry = e.target.getElementsByClassName("entry-name")[0]
    input = entry.getElementsByTagName("input")[0].value
    value = input.replace /^\s+|\s+$/g, ""
    if !!value
      return true
    else
      return false

  handleSubmit: (e) ->
    e.preventDefault()
    if @formIsValid(e)
      prom = Api.savePlayerScore(@formData)
      prom.always =>
        console.log "done"
      prom.fail (err) ->
        console.log("handle error " + err)
      prom.then (res) =>
        console.log res.status
        @props.visibility(false)
  render: ->
    tilesData = []
    @props.cast.forEach (actor) ->
      if actor.profile_path
        tilesData.push({ img: actor.profile_path, name: actor.name, character: actor.character })
    gradientBg = 'linear-gradient(to bottom, rgba(0,0,0,0.7) 0%,rgba(0,0,0,0.3) 70%,rgba(0,0,0,0) 100%)'
    tileElements = _.map tilesData, (tile) ->
      <GridTile key={tile.img} actionPosition="left" titlePosition="top" titleBackground={gradientBg} title={<span className={'profile-title'}>{tile.name}</span>} subtitle={<span className={'profile-subtitle'} >playing {tile.character}</span>}><img className={'profile-image'} src={"http://image.tmdb.org/t/p/w185" + tile.img} /></GridTile>

    <Card>
      <CardTitle title="Nice Round" subtitle={"Score: " + @props.score}/>
      <CardActions className={if @showForm() then 'hidden' else ''}>
        <form onChange={@.updateFormData} onSubmit={@handleSubmit}>
          <TextField className="entry-name" required={true} hintText="Enter Name" name='entry[name]' underlineFocusStyle={{borderColor: "#f44355"}} hintStyle={{color: '#f44355'}}/>
          <br/>
          <FlatButton primary={true} onClick={@handleSkip} label="Skip">
          </FlatButton>
          <FlatButton secondary={true} label="Save to Leaderboard">
            <input className="hidden-input" type="submit" />
          </FlatButton>
        </form>
      </CardActions>
      <div style={{display: 'flex', flexWrap: 'wrap', justifyContent: 'space-around', WebkitOverflowScrolling: "touch"}}>
        <span style={marginBottom: 18}> Here's who you could have guessed</span>
        <GridList cellHeight={278} cols={3} className={"grid-list"} >{tileElements}</GridList>
      </div>
      <CardActions className={if @showButton() then 'hidden' else ''}>
        <FlatButton primary={true} onClick={@handleSkip} label="Play Again"/>
      </CardActions>
    </Card>
