import React from "react";
import { View, Text, TextInput } from "react-native";
import { Button } from 'react-native-elements';
import TimerCountdown from "react-native-timer-countdown";

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
        <Text style={styles.label}>You have</Text>
        <TimerCountdown
          initialMilliseconds={1000 * 300}
          formatMilliseconds={(milliseconds) => {
            const remainingSec = Math.round(milliseconds / 1000);
            const seconds = parseInt((remainingSec % 60).toString(), 10);
            const minutes = parseInt(((remainingSec / 60) % 60).toString(), 10);
            const hours = parseInt((remainingSec / 3600).toString(), 10);
            const s = seconds < 10 ? '0' + seconds : seconds;
            const m = minutes < 10 ? '0' + minutes : minutes;
            let h = hours < 10 ? '0' + hours : hours;
            h = h === '00' ? '' : h + ':';
            return h + m + ':' + s;
          }}
          allowFontScaling={true}
          style={{ fontSize: 20, color: 'black' }}
        />
        <TextInput
          style={styles.text_field}
          onChangeText={guess => {
            this.setState({ guess: guess });
          }}
          value={this.state.guess}
          placeholder={`to pick ${this.props.guessType === 'movie' ? 'a movie' : 'an actor or actress'}`}
          returnKeyType='done'
          onSubmitEditing={() => this.props.handleGuess(this.state.guess)}
        />
      </View>
    );
  }
}

const styles = {
  mainContent: {
    flex: 1,
    justifyContent: 'top',
    alignItems: 'center',
    textAlign: 'center',
    width: '100%'
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
    marginTop: 15,
    marginBottom: 10,
    textAlign: "center"
  }
};
