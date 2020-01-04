import React from 'react';
import { View } from "react-native";
import { Badge, Text } from 'react-native-elements';
import CountDown from 'react-native-countdown-component';

const styles = {
  container: {
    flex: 1, 
    alignItems: "center",
    justifyContent: "center",
    textAlign: "center",
    marginLeft: 5,
    marginRight: 5
  }
}

const ReadyPlayer = props => {
  return (
    <View style={styles.container}>
      {props.challenge && <Badge status="error" value="Challenge!" textStyle={{color: '#FFF', fontSize: 16 }}></Badge>}
      <Text h4>You have </Text>
      <CountDown
        until={60}
        timeToShow={['M', 'S']}
        digitStyle={{ backgroundColor: '#FFF', maxHeight: 60 }}
        size={40}
        onFinish={props.handleTimeUp}
      />
      <Text h4 h4Style={{textAlign: 'center'}}>to name {props.guessType === 'movie' ? props.opponentGuess.length ? `a movie that ${props.opponentGuess} was in.` : `a movie.` : props.opponentGuess.length ? `an actor or actress in ${props.opponentGuess}.` : `an actor or actress.`}</Text>
    </View>
  )
}

const WaitingPlayer = props => {
  return (
    <View style={styles.container}>
      {props.challenge && <Badge status="error" value="Challenge!" textStyle={{color: '#FFF', fontSize: 16 }}></Badge>}
      <Text h4>{props.opponentUsername} has</Text>
      <CountDown
        until={60}
        timeToShow={['M', 'S']}
        digitStyle={{ backgroundColor: '#FFF', maxHeight: 60 }}
        size={40}
      />
      { props.challenge ?
        <Text h4 h4Style={{ textAlign: 'center' }}>to name {props.guessType === 'movie' ? props.opponentGuess.length ? `another movie that ${props.opponentGuess} was in.` : `a movie.` : props.opponentGuess.length ? `another actor or actress in ${props.opponentGuess}.` : `an actor or actress.`}</Text> :
        <Text h4 h4Style={{ textAlign: 'center' }}>to name {props.guessType === 'movie' ? props.myGuess.length ? `a movie that ${props.myGuess} was in.` : `a movie.` : props.myGuess.length ? `an actor or actress in ${props.myGuess}.` : `an actor or actress.`}</Text>
      }

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
