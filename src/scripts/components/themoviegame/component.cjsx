require("./style.scss")
LeaderboardForm = require '../../components/leaderboard_form/component'
MovieList = require '../../components/movie_list/component'
ActorList = require '../../components/actor_list/component'
Api = require "../../services/api"
Loader = require "../../components/loader/component"
_ = require 'underscore'


Card = require 'material-ui/lib/card/card'
CardHeader = require 'material-ui/lib/card/card-header'
Avatar = require 'material-ui/lib/avatar'
CardMedia = require 'material-ui/lib/card/card-media'
CardTitle = require 'material-ui/lib/card/card-title'
CardActions = require 'material-ui/lib/card/card-actions'
FlatButton = require 'material-ui/lib/flat-button'
TextField = require 'material-ui/lib/text-field'
Colors = require 'material-ui/lib/styles/colors'

injectTapEventPlugin = require "react-tap-event-plugin"
injectTapEventPlugin()

module.exports = React.createClass
  displayName: 'TheMovieGame'

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
      ul = document.getElementById("searchResults")
      li = document.createElement('li')
      li.addEventListener('click', @handleAutoComplete)
      li.innerHTML = results[i].name
      ul.appendChild li
      i++
    if ul.className != 'result-list'
      ul.className = 'result-list'

  handleAutoComplete: (e) ->
    @setState({answer: e.target.innerHTML})
    @handleAnswer()

  clearResults: ->
    ul = document.getElementById("searchResults")
    ul.className = 'result-list hidden'
    ul.innerHTML = ''

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
      movie: {},
      actor: {},
      currentActorId: null,
      usedMovies: [],
      usedActors: [],
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
        <h2> Nice {@state.score} Rounds!</h2>
        <h3> Enter your name for the leaderboards </h3>
        <LeaderboardForm score={@state.score} visibility={@toggleModal}/>
      </div>
    else
      if @state.isGuessable
        answer = <TextField hintText="Type Answer" underlineFocusStyle={{borderColor: "#f44355"}} hintStyle={{color: '#f44355'}} onChange={@handleAnswerChange} onEnterKeyDown={@handleAnswer}/>
      else
        answer = <Loader />
      if @state.movie.backdrop_path is null
        question = <CardTitle title="Name an actor or actress in" subtitle={@state.movie.title}/>
      else
        question = <CardMedia overlay={<CardTitle title="Name an actor or actress in" subtitle={@state.movie.title}/>}><img src={"http://image.tmdb.org/t/p/w780" + @state.movie.backdrop_path}/></CardMedia>
      <div className="movie-game-container">
        <Card initiallyExpanded={true}>
          <CardHeader
            title="Score"
            subtitle="get ready to fight"
            avatar={<Avatar>{@state.score}</Avatar>}/>
          {question}
          {answer}
            <ul id="searchResults" className="result-list hidden"></ul>
          <CardActions>
            <FlatButton label="Start Over" onClick={@restart}/>
          </CardActions>
        </Card>
      </div>
