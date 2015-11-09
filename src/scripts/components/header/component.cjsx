require("./style.scss")

module.exports = React.createClass
  render: ->
    <header>
      <nav>
        {@props.children}
      </nav>
    </header>
