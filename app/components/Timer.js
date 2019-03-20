import React from "react";
import { StyleSheet, View, Text } from "react-native";
import TimerCountdown from "react-native-timer-countdown";

export default class Timer extends React.Component {
  render() {

    return (
      <View style={styles.container}>
        <Text>{this.props.turn} has </Text>
        <TimerCountdown
          initialMilliseconds={1000 * 300}
          onExpire={this.props.handleTimeUp}
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
        <Text>to guess { this.props.guessType === 'movie' ? this.props.previousGuess.length ? `a movie that ${this.props.previousGuess} was in.` : `a movie.` : this.props.previousGuess.length ? `an actor or actress in ${this.props.previousGuess}.` : `an actor or actress.` } </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    height: "100%",
    alignItems: "center",
    justifyContent: "center"
  }
});
