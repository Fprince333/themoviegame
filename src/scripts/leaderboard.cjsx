Link = require('react-router').Link
Api = require "./services/api"
_ = require 'underscore'

module.exports = React.createClass
  displayName: 'Leaderboard'

  getInitialState: ->
    members: [],
    totalMembers: null,
    totalPages: null,
    currentPage: null

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
        currentPage: 1
      )

  render: ->
    userList = _.map @state.members, (member) ->
      <tr key={member.rank}>
        <td key={member.rank}>{member.rank}</td>
        <td key={member.member}>{member.member}</td>
        <td key={member.score}> {member.score}</td>
      </tr>
    <table style={margin: '0 auto'}>
      <thead>
        <tr>
          <th>Rank</th>
          <th>Name</th>
          <th>Score</th>
        </tr>
      </thead>
      <tbody>
        {userList}
      </tbody>
    </table>

