require("./style.scss")
FormData = require('react-form-data')
$ = require('jquery')
Api = require("../../services/api")

module.exports = React.createClass
  displayName: 'LeaderboardForm',
  mixins: [ FormData ],

  getInitialFormData: ->
    {
      'entry[score]': @props.score
    }

  handleSubmit: (e) ->
    e.preventDefault()
    prom = Api.savePlayerScore(@formData)
    prom.always =>
      console.log "done"
    prom.fail (err) ->
      console.log("handle error " + err)
    prom.then (res) =>
      console.log res.status
      @props.visibility(false)

  render: ->
    <form onChange={@.updateFormData} onSubmit={@handleSubmit}>
      <input type='text' name='entry[name]'/>
      <input type="submit" value="Submit" />
    </form>
