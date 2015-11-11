require("./style.scss")
LeaderboardForm = require '../../components/leaderboard_form/component'
MovieList = require '../../components/movie_list/component'
ActorList = require '../../components/actor_list/component'
Question = require '../../components/question/component'
Answer = require "../../components/answer/component"
AutoCompleteList = require '../../components/autocomplete/component'
Api = require "../../services/api"
Loader = require "../../components/loader/component"
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
    @setState(showSaveModal: true)

  restart: ->
    @setState(isLoading: true)
    prom = if @state.totalMoviePages > 1 then Api.getRandomMovie(Math.floor(Math.random()*@state.totalMoviePages)) else Api.getRandomMovie(@state.totalMoviePages)
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log "handle error" + err
    prom.then (res) =>
      movie = res.results[Math.floor(Math.random()*res.results.length)]
      movieCheck = @isNotAllowed(movie.genre_ids)
      while movieCheck
        movie = res.results[Math.floor(Math.random()*res.results.length)]
        movieCheck = @isNotAllowed(movie.genre_ids)
        movieCheck
      if movie is @state.movie
        console.log "TODO: Call the restart function again"
      if @state.score > 0
        @replaceState(@getInitialState())
        updatedUsedMovieList = [movie]
      else
        updatedUsedMovieList = @state.usedMovies.concat([movie])
      @setState(
        score: 0,
        movie: movie,
        isLoading: false,
        usedMovies: updatedUsedMovieList,
        isGuessable: true
      )

  continue: ->
    @setState(isLoading: true)
    prom = Api.getNextMovie(@state.currentActorId)
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log "handle error" + err
    prom.then (res) =>
      movieIndex = Math.floor(Math.random()*res.cast.length)
      while @movieHasBeenUsed(res.cast[movieIndex])
        movieIndex++
      while @checkMovie(res.cast[movieIndex].id)
        movieIndex++
      @updateMovieInfo(res.cast[movieIndex].id)

  updateMovieInfo: (movieId) ->
    prom = Api.getMovieInfo(movieId)
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log "handle error" + err
    prom.then (res) =>
      updatedUsedMovieList = @state.usedMovies.concat([res])
      @setState({
        movie: res,
        isLoading: false,
        usedMovies: updatedUsedMovieList,
        isGuessable: true
      })

  checkMovie: (movieId) ->
    check = false
    prom = Api.getMovieInfo(movieId)
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log "handle error" + err
    prom.then (res) =>
      genreIds = []
      res.genres.forEach (el) ->
        genreIds.push(el)
      check = @isNotAllowed(genreIds)
    check

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
    @clearResults()
    return unless e.target.value.length > 3
    guess = e.target.value
    prom = Api.getAutoCompleteOptions(encodeURI(guess))
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log "handle error" + err
    prom.then (res) =>
      if res.results.length > 0
        @appendResults(guess, res.results)
    @setState({answer: e.target.value})

  appendResults: (guess, results) ->
    @clearResults()
    i = 0
    while i < results.length and i < 3
      updatedSuggestedActorsList = @state.suggestedActors.concat([results[i]])
      i++
      @setState(suggestedActors: updatedSuggestedActorsList)
    @setState(showAutoComplete: true)

  handleAutoComplete: (e) ->
    @setState(
      answer: e.target.innerHTML,
      showAutoComplete: false
    )
    @handleAnswer()
    @clearResults()

  clearResults: ->
    @setState(suggestedActors: [])

  handleAnswer: (e) ->
    e.preventDefault() if e
    console.log "Answer: " + @state.answer
    @setState( isGuessable: false )
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
        @setState(showSaveModal: true)

  checkAnswer: (arr, answer) ->
    correct = false
    actorId = null
    arr.forEach (el) ->
      if el.name is answer
        actorId = el.id
        correct = true
    @setState({currentActorId: actorId })
    correct

  getActorInfo: (actor) ->
    prom = Api.getActorInfo(actor)
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log "handle error" + err
    prom.then (res) =>
      @updateActorState(res)

  updateActorState: (actor) ->
    if @actorHasBeenUsed(@state.currentActorId)
      @restart()
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

  isNotAllowed: (idArray) ->
    if _.intersection(@state.disallowedCategories, idArray).length > 0 then return true else return false

  toggleModal: (visibility) ->
    @setState(showSaveModal: visibility)
    @restart()

  getInitialState: ->
    {
      isLoading: true,
      score: 0,
      answer: null,
      movie: {},
      actor: {},
      currentActorId: null,
      usedMovies: [],
      usedActors: [],
      suggestedActors: [],
      showAutoComplete: false,
      disallowedCategories: [10770, 99, 10769, 16],
      totalMoviePages: 1,
      isGuessable: true,
      showSaveModal: false
    }

  componentDidMount: ->
    prom = Api.getRandomMovie(@state.totalMoviePages)
    prom.always =>
      console.log("done")
    prom.fail (err) ->
      console.log("handle error " + err)
      @setState(isLoading: false)
    prom.then (res) =>
      totalPages = res.total_pages
      movie = res.results[Math.floor(Math.random()*res.results.length)]
      movieCheck = @isNotAllowed(movie.genre_ids)
      while movieCheck
        movie = res.results[Math.floor(Math.random()*res.results.length)]
        movieCheck = @isNotAllowed(movie)
        movieCheck
      updatedUsedMovieList = @state.usedMovies.concat([movie])
      @setState(
        movie: movie,
        usedMovies: updatedUsedMovieList
        isLoading: false,
        totalMoviePages: totalPages
      )

  render: ->
    if @state.isLoading
      <Loader />
    else if @state.showSaveModal
      <div className="movie-game-container">
        <LeaderboardForm score={@state.score} visibility={@toggleModal}/>
      </div>
    else
      if @state.score > 0
        button = <FlatButton label="Give Up" primary={true} onClick={@giveUp}/>
      else
        button = <FlatButton label="Start Over" secondary={true} onClick={@restart}/>
      <div className="movie-game-container">
        <Card initiallyExpanded={true}>
          <CardHeader
            textStyle={{verticalAlign: "super"}}
            title="Score"
            avatar={<Avatar>{@state.score}</Avatar>}/>
          <Question hasPoster={@state.movie.backdrop_path} movie={@state.movie}/>
          <Answer isGuessable={@state.isGuessable} onChange={@handleAnswerChange} onEnterKeyDown={@handleAnswer}/>
          <AutoCompleteList actors={@state.suggestedActors} visible={@state.showAutoComplete} onClick={@handleAutoComplete}/>
          <CardActions style={textAlign: "right"} >
            {button}
          </CardActions>
        </Card>
      </div>
