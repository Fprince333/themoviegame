Link = require('react-router').Link
Api = require "./services/api"
Loader = require "./components/loader/component"
_ = require 'underscore'
Table = require 'material-ui/lib/table/table'
TableHeader = require 'material-ui/lib/table/table-header'
TableHeaderColumn = require 'material-ui/lib/table/table-header-column'
TableBody = require 'material-ui/lib/table/table-body'
TableRow = require 'material-ui/lib/table/table-row'
TableRowColumn = require 'material-ui/lib/table/table-row-column'
Card = require 'material-ui/lib/card/card'

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
      console.log "handle " + err.status + " " + err.statusText
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

  # componentWillUpdate: (nextProps, nextState) ->
  #   if nextState.fetchUsers and @state.currentScrollPosition < nextState.currentScrollPosition
  #     @loadMoreUsers()
  #     return true
  #   else
  #     return false

  # handleScroll: (e) ->
  #   containerHeight = e.target.parentNode.scrollHeight
  #   tableHeight = e.target.lastChild.getElementsByClassName('mui-table-body')[0].offsetHeight
  #   scrollPosition = e.target.scrollTop
  #   @setState(currentScrollPosition: scrollPosition)
  #   @handleUserFetching(containerHeight, tableHeight, scrollPosition)

  # handleUserFetching: (cHeight, tHeight, position) ->
  #   SMALL_BREAKPOINT = 553
  #   SMALL_CONTAINER  = 480
  #   LARGE_BREAKPOINT = 267
  #   LARGE_CONTAINER  = 768

  #   if cHeight is SMALL_CONTAINER
  #     if (position / SMALL_BREAKPOINT) % 1 is 0
  #       @loadMoreUsers()

  #   if cHeight is LARGE_CONTAINER
  #     if (position / LARGE_BREAKPOINT) % 1 is 0
  #       @loadMoreUsers()
  #   # console.log "Container Height: " + cHeight
  #   # console.log "Table Height: " + tHeight
  #   console.log "Scroll Position: " + position

  loadMoreUsers: ->
    nextPage = @state.currentPage + 1
    prom = Api.getNextPageOfScores(nextPage)
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log "handle " + err.status + " " + err.statusText
    prom.then (res) =>
      moreLeaders = res.members
      updatedLeaderList = @state.members.concat(moreLeaders)
      @setState(
        members: updatedLeaderList,
        currentPage: nextPage
      )

  _handleWaypointEnter: ->
    debugger

  _handleWaypointLeave: ->
    debugger

  render: ->
    if @state.isLoading
      <Loader />
    else
      waypoint = <Waypoint key={"fuck"} onEnter={@_handleWaypointEnter} onLeave={@_handleWaypointLeave} threshold={0.2}></Waypoint>
      userList = _.map @state.members, (user, key, users) ->
        if key % 20 is 0 and key isnt 0
          <TableRow key={key}>
            <TableRowColumn style={{textAlign: 'center'}} key={user.rank} >{user.rank}</TableRowColumn>
            <TableRowColumn style={{textAlign: 'center'}} key={user.member}>{user.member}</TableRowColumn>
            <TableRowColumn style={{textAlign: 'center'}} key={user.score}>{user.score}</TableRowColumn>
          </TableRow>
        else
          <TableRow key={key}>
            <TableRowColumn style={{textAlign: 'center'}} key={user.rank} >{user.rank}</TableRowColumn>
            <TableRowColumn style={{textAlign: 'center'}} key={user.member}>{user.member}</TableRowColumn>
            <TableRowColumn style={{textAlign: 'center'}} key={user.score}>{user.score}</TableRowColumn>
          </TableRow>
      <div className="movie-game-container" style={WebkitOverflowScrolling: "touch"}>
        <Card initiallyExpanded={true}>
          <Table>
            <TableHeader displaySelectAll={false}>
              <TableRow>
                <TableHeaderColumn style={{textAlign: 'center'}}>Rank</TableHeaderColumn>
                <TableHeaderColumn style={{textAlign: 'center'}}>Name</TableHeaderColumn>
                <TableHeaderColumn style={{textAlign: 'center'}}>Score</TableHeaderColumn>
              </TableRow>
            </TableHeader>
            <TableBody displayRowCheckbox={false} stripedRows={false} showRowHover={false}>
              {userList}
            </TableBody>
          </Table>
        </Card>
        {waypoint}
      </div>

