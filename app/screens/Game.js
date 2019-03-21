import React from "react";
import { View, KeyboardAvoidingView, Alert } from "react-native";
import { Button, Text } from 'react-native-elements';
import Icon from 'react-native-vector-icons/FontAwesome';

import Guess from "../components/Guess";
import Timer from "../components/Timer";

import formatChannelName from "../helpers/formatChannelName";

export default class Game extends React.Component {
  static navigationOptions = ({ navigation }) => {
    return {
      headerTitle: 'The Movie Game',
      headerStyle: {
        backgroundColor: "#2089dc"
      },
      headerTitleStyle: {
        color: "#FFF"
      },
      headerLeft: <Button
        type='clear'
        title='Back'
        icon={
          <Icon name='arrow-left' size={15} color="white" />
        }
        titleStyle={{
          color: "white",
          fontSize: 15,
          marginLeft: 5
        }}
        onPress={() => {
          navigation.getParam("my_channel").trigger("client-opponent-won", {
            winner: navigation.getParam("opponent"),
            reason: "Your opponent exited the game."
          });
          navigation.navigate("Login", {})
        }}
      />
    };
  };

  state = {
    my_guess: '',
    turn: null,
    opponent_guess: '',
    guessType: 'movie'
  }

  constructor(props) {
    super(props);

    this.pusher = null;
    this.my_channel = null;
    this.opponent_channel = null;
    this.username = null;
    this.opponent = null;
  }

  componentDidMount() {
    const { navigation } = this.props;

    this.pusher = navigation.getParam("pusher");
    this.my_channel = navigation.getParam("my_channel");

    this.username = navigation.getParam("username");
    this.opponent = navigation.getParam("opponent");

    this.setState({
      turn: navigation.getParam("starter")
    })

    if (this.opponent) {
      this.opponent_channel = this.pusher.subscribe(
        `private-user-${formatChannelName(this.opponent)}`
      );
      this.opponent_channel.bind("pusher:subscription_error", status => {
        Alert.alert("Subscription error", status);
      });

      this.opponent_channel.bind("pusher:subscription_succeeded", data => {
        console.log("opponent subscription ok: ", data);
        this.opponent_channel.bind("client-opponent-guessed", data => {
          console.log("opponent guess: ", data);
          this.setState({
            turn: data.turn,
            guessType: data.guessType,
            opponent_guess: data.guess
          });
        });

        this.opponent_channel.bind("client-opponent-won", data => {
          Alert.alert(
            `Congrats ${data.winner}, you won!`,
            `${data.reason}`
          );
          this.props.navigation.navigate("Login", {});
        });

        // this.opponent_channel.bind("client-opponent-challenged", data => {
        //   console.log(data.guessType);
        //   console.log(data.guess);
        // });

      });
    }
  }

  handleGameOver = () => {
    // ToFix
    Alert.alert(
      `Sorry, ${this.opponent} won.`,
      `"You ran out of time."`
    );
    this.my_channel.trigger("client-opponent-won", {
      winner: this.username,
      reason: "Your opponent ran out of time."
    });
    this.props.navigation.navigate("Login", {});
  }

  handleGuessSubmit = guess => {

    const turn = this.state.turn === this.username ? this.opponent : this.username;
    const guessType = this.state.guessType === "movie" ? "actor" : "movie";
    this.setState({
      turn: turn,
      guessType: guessType,
      my_guess: guess
    });
    this.my_channel.trigger("client-opponent-guessed", {
      turn: turn,
      guessType: guessType,
      guess: guess
    })

  };

  handleChallengePrevious = () => {
    // TODO: Check against movie database api to verify answer
  }

  handleChallengeNext = () => {
    // TODO: Send challenge via pusher to opponent to answer
  }

  resetGame = () => {
    this.props.navigation.navigate("Login", {});
  };

  render() {
    console.log(`${this.username}'s state: ${JSON.stringify(this.state)}`)
    return (
      <KeyboardAvoidingView style={styles.container} behavior="padding" enabled>
        <View style={styles.topContent}>
          <Text h2>{this.username} vs {this.opponent}</Text>
        </View>
        {this.state.turn === this.username ? <View style={styles.container}><Text h1>Name {this.state.guessType === 'movie' ? this.state.opponent_guess.length ? `a movie that ${this.state.opponent_guess} was in.` : `a movie.` : this.state.opponent_guess.length ? `an actor or actress in ${this.state.opponent_guess}.` : `an actor or actress.`}</Text></View> : <View style={styles.container}><Text h1>{this.opponent}'s Turn</Text></View>}
        {this.state.turn === this.username ?
          <Guess
            handleGuess={guess => this.handleGuessSubmit(guess)}
            guessType={this.state.guessType}
            previousGuess={this.state.opponent_guess}
            handleChallengePrevious={() => this.handleChallengePrevious()}
            handleChallengeNext={() => this.handleChallengeNext()} /> :
          <Timer
            handleTimeUp={() => this.handleGameOver()}
            turn={this.state.turn}
            guessType={this.state.guessType}
            previousGuess={this.state.my_guess} /> }
      </KeyboardAvoidingView>
    );
  }
}

const styles = {
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "flex-start",
    marginLeft: 5,
    marginRight: 5
  },
  topContent: {
    flex: 1,
    justifyContent: "center"
  },
  bigText: {
    fontSize: 25,
    fontWeight: "bold"
  },
  mainContent: {
    flex: 1,
    justifyContent: "flex-start"
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
