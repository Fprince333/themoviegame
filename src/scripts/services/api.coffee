MovieGameApi = require './moviegameapi'
MovieDbApi   = require './moviedbapi'

module.exports =
  savePlayerScore: (player) -> MovieGameApi.post('/entries', player)
  getScores: -> MovieGameApi.get('/leaderboards')
  getNextPageOfScores: (page) -> MovieGameApi.get('/leaderboards?page=' + page.toString())
  getRandomMovie: (num) -> MovieDbApi.get('/movie/top_rated' + '?page=' + (num.toString()) + "&")
  getMovieInfo: (movie) -> MovieDbApi.get('/movie/' + movie + '?')
  getMovieCredits: (movie) -> MovieDbApi.get('/movie/' + movie + '/credits?')
  getActorInfo: (actor) -> MovieDbApi.get('/person/' + actor + '?')
  getAutoCompleteOptions: ( query ) -> MovieDbApi.get('/search/person?query=' + query + '&search_type=ngram&')
  getNextMovie: (actorId) -> MovieDbApi.get('/person/' + actorId + '/movie_credits?')
