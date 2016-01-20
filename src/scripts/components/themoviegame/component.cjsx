require("./style.scss")
Summary = require '../../components/summary/component'
MovieList = require '../../components/movie_list/component'
ActorList = require '../../components/actor_list/component'
Question = require '../../components/question/component'
Answer = require "../../components/answer/component"
AutoCompleteList = require '../../components/autocomplete/component'
Api = require "../../services/api"
Checker = require "../../services/checker"
Loader = require "../../components/loader/component"
Snackbar = require 'material-ui/lib/snackbar'
Dialog = require 'material-ui/lib/dialog'
_ = require 'underscore'


Card = require 'material-ui/lib/card/card'
CardHeader = require 'material-ui/lib/card/card-header'
Avatar = require 'material-ui/lib/avatar'
CardActions = require 'material-ui/lib/card/card-actions'
FlatButton = require 'material-ui/lib/flat-button'
Colors = require 'material-ui/lib/styles/colors'


injectTapEventPlugin = require "react-tap-event-plugin"
injectTapEventPlugin()

module.exports = React.createClass
  displayName: 'TheMovieGame'

  giveUp: ->
    @setState(
      showSaveModal: true
      gameOverMessage: "Get 'em next time."
    )

  restart: ->
    prom = if @state.totalMoviePages > 1 then Api.getRandomMovie(Math.floor(Math.random()*@state.totalMoviePages)) else Api.getRandomMovie(Math.floor(Math.random()*50) + 1)
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log "handle " + err.status + " " + err.statusText
    prom.then (res) =>
      totalPages = if res.total_pages > 1000 then Math.floor(Math.random()*1000) else res.total_pages
      movie = res.results[Math.floor(Math.random()*res.results.length)]
      if Checker.isNotReleased(movie.release_date)
        @restart()
      else if Checker.isTooOld(movie.release_date)
        @restart()
      else if Checker.isTooObscure(movie.popularity)
        @restart()
      else if Checker.isNotAllowed(movie.genre_ids)
        @restart()
      else if movie.original_language isnt "en"
        @restart()
      else if Checker.hasNoPoster(movie)
        @restart()
      else if movie is @state.movie
        @restart()
      else
        if @state.score > 0
          @replaceState(@getInitialState())
          updatedUsedMovieList = [movie]
        else
          updatedUsedMovieList = @state.usedMovies.concat([movie])
        @setState(
          score: 0,
          movie: movie,
          usedMovies: updatedUsedMovieList,
          isGuessable: true,
          totalMoviePages: totalPages
        )

  continue: ->
    prom = Api.getNextMovie(@state.currentActorId)
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log "handle " + err.status + " " + err.statusText
    prom.then (res) =>
      movieIndex = Math.floor(Math.random()*(res.cast.length - 1))
      while @movieHasBeenUsed(res.cast[movieIndex])
        movieIndex++
      while res.cast.length < 5
        movieIndex++
      @updateMovieInfo(res.cast[movieIndex].id)

  updateMovieInfo: (movieId) ->
    prom = Api.getMovieInfo(movieId)
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log "handle " + err.status + " " + err.statusText
    prom.then (res) =>
      updatedUsedMovieList = @state.usedMovies.concat([res])
      @setState(
        movie: res,
        usedMovies: updatedUsedMovieList
      )

  movieHasBeenUsed: (mov) ->
    used = false
    @state.usedMovies.forEach (el) ->
      if el.id is mov.id
        used = true
    used

  actorHasBeenUsed: (act) ->
    used = false
    if @state.usedActors.length > 0
      @state.usedActors.forEach (el) ->
        if el.id is act
          used = true
    used

  handleAnswerChange: (e) ->
    return unless e.target.value.length > 3
    guess = e.target.value
    prom = Api.getAutoCompleteOptions(encodeURI(guess))
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log "handle " + err.status + " " + err.statusText
    prom.then (res) =>
      if res.results.length > 0
        @appendResults(res.results)
    @setState(answer: e.target.value)

  appendResults: (results) ->
    @clearResults()
    i = 0
    while i < results.length and i < 3
      updatedSuggestedActorsList = @state.suggestedActors.concat([results[i]])
      i++
      @setState(suggestedActors: updatedSuggestedActorsList)
    @setState(showAutoComplete: true)

  clearResults: ->
    @setState(
      suggestedActors: [],
      showAutoComplete: false
    )

  handleAnswer: (e) ->
    e.preventDefault() if e
    dirtyGuess = e.target.value || e.target.innerText
    guessWithoutSpecialCharacter = dirtyGuess.replace("↵", "")
    cleanGuess = guessWithoutSpecialCharacter.trim()
    @setState(
      isGuessable: false ,
      showAutoComplete: false,
      answer: cleanGuess
    )
    prom = Api.getMovieCredits(@state.movie.id.toString())
    prom.always =>
      console.log("done")
    prom.fail (err) ->
      console.log("handle error " + err)
    prom.then (res) =>
      isCorrect = @checkAnswer(res.cast, @state.answer)
      if isCorrect
        @getActorInfo(@state.currentActorId)
      else
        @setState(
          showSaveModal: true,
          gameOverMessage: @state.answer + " wasn't in " + @state.movie.title
        )

  checkAnswer: (arr, answer) ->
    correct = false
    actorId = null
    arr.forEach (el) ->
      if el.name.toLowerCase() is answer.toLowerCase()
        actorId = el.id
        correct = true
    @setState({currentActorId: actorId })
    correct

  getActorInfo: (actor) ->
    prom = Api.getActorInfo(actor)
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log "handle " + err.status + " " + err.statusText
    prom.then (res) =>
      @updateActorState(res)

  updateActorState: (actor) ->
    if @actorHasBeenUsed(@state.currentActorId)
      @setState(
        showSaveModal: true,
        gameOverMessage: @state.answer + " has already been used."
      )
      return
    updatedUsedActorList = @state.usedActors.concat([actor])
    @setState({
      actor: actor,
      usedActors: updatedUsedActorList
    })
    @updateGame()

  updateGame: ->
    newScore = this.state.score + 1
    @setState({
      score: newScore
    })
    @continue()

  toggleModal: (visibility) ->
    @setState(showSaveModal: visibility)
    @restart()

  getInitialState: ->
    {
      score: 0,
      answer: null,
      movie: {},
      actor: {},
      currentActorId: null,
      usedMovies: [],
      usedActors: [],
      suggestedActors: [],
      showAutoComplete: false,
      disallowedCategories: [10770, 99, 10769, 16, 10751],
      totalMoviePages: 1,
      isGuessable: true,
      showSaveModal: false,
      gameOverMessage: "",
      showRules: true
    }

  componentWillMount: ->
    @restart()

  shouldComponentUpdate: (newProps, newState) ->
    if newState.movie isnt @state.movie and not _.isEmpty(newState.movie) and @state.score > 0
      genres = []
      newState.movie.genres.forEach (el) ->
        genres.push(el.id)
      if Checker.isNotReleased(newState.movie.release_date)
        @continue()
        return false
      else if Checker.isTooObscure(newState.movie.popularity)
        @continue()
        return false
      else if Checker.isNotAllowed(genres)
        @continue()
        return false
      else if newState.movie.original_language isnt "en"
        @continue()
        return false
      else if Checker.isTooOld(newState.movie.release_date)
        @continue()
        return false
      else if Checker.hasNoPoster(newState.movie)
        @continue()
        return false
      else
        @setState( isGuessable: true )
        return true
    else
      return true

  _onDialogSubmit: ->
    window.localStorage.setItem("hasReadRules", true);
    @setState( showRules: false )

  render: ->
    standardActions = [ { text: 'OK', onTouchTap: @_onDialogSubmit } ]
    rules = <div>
              <p>You name an actor or actress from the movie on the screen. </p>
              <p>If you're right, you have to name another actor or actress in the next movie.</p>
              <p> Be careful - you can only use an actor once.</p>
              <p> Get the highest possible score and try to beat the leaders.</p>
              <p>Good Luck.</p>
            </div>
    if @state.showSaveModal
      <div className="movie-game-container">
        <Summary score={@state.score} visibility={@toggleModal} answer={@state.answer} movie={@state.movie} />
        <Snackbar
          message={@state.gameOverMessage}
          openOnMount={@state.showSaveModal} />
      </div>
    else
      if @state.score > 0
        button = <FlatButton label="Give Up" primary={true} onClick={@giveUp}/>
      else
        button = <FlatButton label="Start Over" secondary={true} onClick={@restart}/>
      if window.localStorage.getItem("hasReadRules") isnt "true" and @state.showRules
        dialog = <Dialog autoScrollBodyContent={true} openImmediately={true} title="Welcome to The Movie Game" actions={standardActions} open={@state.showDialogStandardActions}>{rules}</Dialog>
      else
        dialog = null
      <div>
        <div className="movie-game-container">
          <Card initiallyExpanded={true}>
            <CardHeader
              textStyle={{verticalAlign: "super"}}
              title="Score"
              avatar={<Avatar>{@state.score}</Avatar>}/>
            <Question movie={@state.movie}/>
            <Answer isGuessable={@state.isGuessable} onChange={@handleAnswerChange} onEnterKeyDown={@handleAnswer}/>
            <AutoCompleteList actors={@state.suggestedActors} visible={@state.showAutoComplete} onClick={@handleAnswer}/>
            <CardActions style={textAlign: "right"} >
              {button}
            </CardActions>
          </Card>
        </div>
        {dialog}
      </div>
