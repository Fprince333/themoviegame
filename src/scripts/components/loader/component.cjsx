RefreshIndicator = require 'material-ui/lib/refresh-indicator'

module.exports = React.createClass
  render: ->
    styles = {
      position: "relative",
      margin: "0 auto"
    }
    <RefreshIndicator style={styles} size={40} left={0} top={50} status="loading" />
