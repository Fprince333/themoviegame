require("./style.scss")
_ = require 'underscore'
Table = require 'material-ui/lib/table/table'
TableHeader = require 'material-ui/lib/table/table-header'
TableHeaderColumn = require 'material-ui/lib/table/table-header-column'
TableBody = require 'material-ui/lib/table/table-body'
TableRow = require 'material-ui/lib/table/table-row'
TableRowColumn = require 'material-ui/lib/table/table-row-column'
Card = require 'material-ui/lib/card/card'

module.exports = React.createClass
  displayName: 'TheMovieGame'

  render: ->
    userList = _.map @props.users, (user) ->
      <TableRow key={user.rank}>
        <TableRowColumn style={{textAlign: 'center'}} key={user.rank} >{user.rank}</TableRowColumn>
        <TableRowColumn style={{textAlign: 'center'}} key={user.member}>{user.member}</TableRowColumn>
        <TableRowColumn style={{textAlign: 'center'}} key={user.score}>{user.score}</TableRowColumn>
      </TableRow>
    <div className="movie-game-container">
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
