import React from "react";
import { Button, View, Text, TextInput } from "react-native";

export default class Guess extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      guess: ""
    }
  }

  render() {

    return (
      <View style={styles.mainContent}>
        <Text style={styles.label}>Name {this.props.guessType === 'movie' ? this.props.previousGuess.length ? `a movie that ${this.props.previousGuess} was in.` : `a movie.` : this.props.previousGuess.length ? `an actor or actress in ${this.props.previousGuess}.` : `an actor or actress.`}</Text>
        <TextInput
          style={styles.text_field}
          onChangeText={guess => {
            this.setState({ guess: guess });
          }}
          value={this.state.guess}
          placeholder={`Pick ${this.props.guessType === 'movie' ? 'a movie' : 'an actor or actress'}`}
        />
        {this.state.guess.length ? <Button onPress={() => this.props.handleGuess(this.state.guess)} title="Enter" color="#0064e1" /> : null }
      </View>
    );
  }
}

const styles = {
  mainContent: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center"
  },
  label: {
    marginBottom: 5,
    fontSize: 15,
    fontWeight: "bold",
    color: "#333"
  },
  text_field: {
    width: 200,
    height: 40,
    borderColor: "#bfbfbf",
    borderWidth: 1,
    padding: 10,
    marginBottom: 10
  }
};
