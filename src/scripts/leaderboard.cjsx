Link = require('react-router').Link
Api = require "./services/api"
Loader = require "./components/loader/component"
LeaderboardTable = require './components/leaderboard/component'

module.exports = React.createClass
  displayName: 'Leaderboard'

  getInitialState: ->
    members: [],
    totalMembers: null,
    totalPages: null,
    currentPage: null,
    isLoading: true

  componentDidMount: ->
    window.scroll(0,0)
    prom = Api.getScores()
    prom.always =>
      console.log("done")
    prom.fail (err) ->
      console.log("handle error " + err)
    prom.then (res) =>
      leaders = res.members
      allLeaders = res.total_members
      allPages = res.total_pages
      @setState(
        members: leaders,
        totalMembers: allLeaders,
        totalPages: allPages,
        currentPage: 1,
        isLoading: false
      )

  render: ->
    if @state.isLoading
      <Loader />
    else
      <LeaderboardTable users={@state.members} />

