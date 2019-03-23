import React from 'react';
import { View } from "react-native";
import { Text } from 'react-native-elements';
import CountDown from 'react-native-countdown-component';

const styles = {
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "flex-start",
    marginLeft: 5,
    marginRight: 5
  }
}

const ReadyPlayer = props => {
  return (
    <View style={styles.container}>
      <Text h3>You have </Text>
      <CountDown
        until={120}
        timeToShow={['M', 'S']}
        digitStyle={{ backgroundColor: '#FFF', maxHeight: 60 }}
        size={40}
      />
      <Text h3>to name {props.guessType === 'movie' ? props.opponent_guess.length ? `a movie that ${props.opponent_guess} was in.` : `a movie.` : props.opponent_guess.length ? `an actor or actress in ${props.opponent_guess}.` : `an actor or actress.`}</Text>
    </View>
  )
}

const WaitingPlayer = props => {
  return (
    <View style={styles.container}>
      <Text h3>{props.opponent} has</Text>
      <CountDown
        until={120}
        timeToShow={['M', 'S']}
        digitStyle={{ backgroundColor: '#FFF', maxHeight: 60 }}
        size={40}
        onFinish={props.handleTimeUp}
      />
      <Text h3>to name {props.guessType === 'movie' ? props.opponent_guess.length ? `a movie that ${props.opponent_guess} was in.` : `a movie.` : props.opponent_guess.length ? `an actor or actress in ${props.opponent_guess}.` : `an actor or actress.`}</Text>
    </View>
  )
}

class GameStatus extends React.Component {
  constructor(props) {
    super(props);
    this.state = {  }
  }
  render() {
    return (
      this.props.turn === this.props.player ? <ReadyPlayer {...this.props} /> : <WaitingPlayer {...this.props} />
    );
  }
}

export default GameStatus;
