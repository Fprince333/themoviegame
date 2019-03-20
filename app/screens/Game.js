import React from "react";
import { View, Text, Button, Alert } from "react-native";
import { FontAwesome, Entypo } from "@expo/vector-icons";

import Guess from "../components/Guess";
// import OpponentGuess from "../components/OpponentGuess";
import Timer from "../components/Timer";

import formatChannelName from "../helpers/formatChannelName";

export default class Game extends React.Component {
  static navigationOptions = () => {
    return {
      headerTitle: `The Movie Game`,
      headerStyle: {
        backgroundColor: "#333"
      },
      headerTitleStyle: {
        color: "#FFF"
      }
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
        });

      });
    }
  }

  handleGameOver = () => {
    // FIX ME, this is reversed
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
    // const isNotCorrect = false;

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

  resetGame = () => {
    this.props.navigation.navigate("Login", {});
  };

  render() {
    console.log(`${this.username}'s state: ${JSON.stringify(this.state)}`)
    return (
      <View style={styles.container}>
        <View style={styles.topContent}>
          <Text style={styles.bigText}>The Movie Game</Text>
          <Text style={styles.label}>{this.username}</Text>
        </View>
        {this.state.turn === this.username ?
          <Guess
            handleGuess={guess => this.handleGuessSubmit(guess)}
            handleTimeUp={() => this.handleGameOver()}
            guessType={this.state.guessType}
            previousGuess={this.state.opponent_guess} /> :
          <Timer
            handleTimeUp={() => this.handleGameOver()}
            turn={this.state.turn}
            guessType={this.state.guessType}
            previousGuess={this.state.my_guess} /> }
      </View>
    );
  }
}

const styles = {
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center"
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
    flex: 1
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
