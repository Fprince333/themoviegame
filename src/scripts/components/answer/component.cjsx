TextField = require 'material-ui/lib/text-field'
Loader = require "../../components/loader/component"

module.exports = React.createClass
  render: ->
    if @props.isGuessable
      <TextField hintText="Type Answer" underlineFocusStyle={{borderColor: "#f44355"}} hintStyle={{color: '#f44355'}} onChange={@props.onChange} onEnterKeyDown={@props.onEnterKeyDown}/>
    else
      <div></div>
