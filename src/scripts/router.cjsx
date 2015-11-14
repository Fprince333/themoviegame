require '../../public/main.css'

React = require 'react'
window.React = React

Router = require('react-router')
Route = Router.Route

ReactDOM = require('react-dom')

Play = require './play'
Leaderboard = require './leaderboard'
App = require './app'

routes = (
  <Route handler={App}>
    <Route name="play" handler={Play} path="/play" />
    <Route name="leaderboard" handler={Leaderboard} path="/leaderboard" />
  </Route>
)
Router.run(routes, (Handler) ->
  ReactDOM.render <Handler/>, document.getElementById 'app'
)
