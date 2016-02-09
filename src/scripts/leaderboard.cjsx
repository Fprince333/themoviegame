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
$ = require 'jquery'

module.exports = React.createClass
  displayName: 'Leaderboard'

  getInitialState: ->
    members: [],
    totalMembers: null,
    totalPages: null,
    currentPage: null,
    isLoading: true,
    scrollPosition: null,
    loadMoreUsers: false

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

  handleScroll: (e) ->
    currentScroll = $(e.target).scrollTop()
    previousScroll = @state.scrollPosition
    win = $('.users-container')
    viewport = top: win.scrollTop(), left: win.scrollLeft()
    viewport.right = viewport.left + win.width()
    viewport.bottom = viewport.top + win.height()

    bounds = $('.trigger').offset()
    bounds.right = bounds.left + $('.trigger').outerWidth()
    bounds.bottom = bounds.top + $('.trigger').outerHeight()

    if (!(viewport.right < bounds.left || viewport.left > bounds.right || viewport.bottom < bounds.top || viewport.top > bounds.bottom))
      if previousScroll < currentScroll and @state.currentPage < @state.totalPages and @state.members.length < @state.totalMembers
        @setState(loadMoreUsers: true)
        @loadMoreUsers()
    @setState(scrollPosition: currentScroll)

  loadMoreUsers: ->
    console.log "Load more..."
    if @state.members.length < @state.totalMembers and @state.loadMoreUsers
      @setState(loadMoreUsers: false)
      nextPage = @state.currentPage + 1
      prom = Api.getNextPageOfScores(nextPage)
      prom.always =>
        console.log "done"
      prom.fail (err) ->
        console.log "handle " + err.status + " " + err.statusText
      prom.then (res) =>
        moreLeaders = res.members
        updatedLeaderList = @state.members.concat(moreLeaders)
        @setState(members: updatedLeaderList, currentPage: nextPage)
    else
      return

  render: ->
    if @state.isLoading
      <Loader />
    else
      userList = _.map @state.members, (user, key, users) ->
        if key is users.length - 5
          <TableRow key={key} className={"trigger"}>
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
      <div className="movie-game-container users-container" style={WebkitOverflowScrolling: "touch"} onScroll={@handleScroll}>
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
      </div>

