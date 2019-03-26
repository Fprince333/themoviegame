import React from "react";
import { View, KeyboardAvoidingView, Alert } from "react-native";
import { Button, Text } from 'react-native-elements';
import Icon from 'react-native-vector-icons/FontAwesome';

import Guess from "../components/Guess";
import GameStatus from '../components/GameStatus';

import formatChannelName from "../helpers/formatChannelName";
import { movieApi } from "../helpers/theMovieDatabase";

const styles = {
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "flex-start",
    marginLeft: 5,
    marginRight: 5
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

export default class Game extends React.Component {
  static navigationOptions = ({ navigation }) => {
    return {
      headerTitle: `TMG: ${navigation.getParam("username")} vs ${navigation.getParam("opponent")}`,
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
            winner: "You",
            reason: "Your opponent exited the game."
          });
          navigation.navigate("Login", {})
        }}
      />
    };
  };

  constructor(props) {
    super(props);
    this.pusher = null;
    this.my_channel = null;
    this.opponent_channel = null;
    this.username = null;
    this.opponent = null;
    this.state = {
      turn: null,
      my_guess: '',
      opponent_guess: '',
      guessType: 'movie',
      isReadyToPlay: false,
      challenge: false
    }
  }

  componentDidMount() {
    const { navigation } = this.props;

    this.pusher = navigation.getParam("pusher");
    this.my_channel = navigation.getParam("my_channel");

    this.username = navigation.getParam("username");
    this.opponent = navigation.getParam("opponent");

    this.setState({
      turn: navigation.getParam("starter"),
      isReadyToPlay: true
    })

    this.opponent_channel = this.pusher.subscribe(
      `private-user-${formatChannelName(this.opponent)}`
    );

    this.opponent_channel.bind("pusher:subscription_error", status => {
      Alert.alert("Subscription error", status);
    });

    this.opponent_channel.bind("pusher:subscription_succeeded", data => {
      console.log("opponent subscription ok: ", this.opponent);
      this.opponent_channel.bind("client-opponent-guessed", data => {
        console.log("opponent guess: ", data.guess);
        this.setState({
          turn: data.turn,
          guessType: data.guessType,
          opponent_guess: data.guess,
          challenge: data.isChallenge
        });
      });

      this.opponent_channel.bind("client-opponent-won", data => {
        console.log("winner: ", data.winner);
        Alert.alert(
          `${data.winner} won`,
          `${data.reason}`
        );
        this.setState({ isReadyToPlay: false });
        this.props.navigation.navigate("Login", {});
      });

    });

  }

  restart = () => {
    const turn = this.state.turn === this.username ? this.opponent : this.username;
    const guessType = "movie";
    this.setState({
      turn: turn,
      guessType: guessType
    });
    this.my_channel.trigger("client-opponent-guessed", {
      turn: turn,
      guessType: guessType,
      guess: ""
    })
  }

  random = async () => {
    const turn = this.state.turn === this.username ? this.opponent : this.username;
    const guessType = "actor";
    const randomMovie = await movieApi.getRandomMovie();
    this.setState({
      turn: turn,
      guessType: guessType,
      my_guess: randomMovie
    });
    this.my_channel.trigger("client-opponent-guessed", {
      turn: turn,
      guessType: guessType,
      guess: randomMovie
    })
  }

  handleGameOver = () => {
    this.my_channel.trigger("client-opponent-won", {
      winner: "You",
      reason: `${this.username} ran out of time.`
    });
    Alert.alert(
      `You Lost`,
      `You ran out of time.`
    );
    this.props.navigation.navigate("Login", {});
  }

  handleGuessSubmit = async guess => {
    if (this.state.challenge && this.state.guessType === "actor") {
      const movieId = await movieApi.getMovieId(this.state.my_guess);
      const isInMovie = await movieApi.isActorInMovie(guess, movieId);
      if (isInMovie) {
        this.my_channel.trigger("client-opponent-won", {
          winner: this.opponent,
          reason: `${this.state.my_guess} was in ${guess}`
        });
        Alert.alert(
          `You lost`,
          `${this.state.my_guess} was in ${guess}`
        );
        this.props.navigation.navigate("Login", {});
      } else {
        this.opponent_channel.trigger("client-opponent-won", {
          winner: this.username,
          reason: `${this.state.my_guess} wasn't in ${guess}`
        });
        Alert.alert(
          `You won!`,
          `${this.state.my_guess} wasn't in ${guess}`
        );
        this.props.navigation.navigate("Login", {});
      }
    } else if (this.state.challenge && this.state.guessType === "movie") {
      const movieId = await movieApi.getMovieId(guess);
      const isInMovie = await movieApi.isActorInMovie(this.state.opponent_guess, movieId);
      if (isInMovie) {
        this.my_channel.trigger("client-opponent-won", {
          winner: this.username,
          reason: `${this.state.opponent_guess} was in ${guess}`
        });
        Alert.alert(
          `You won!`,
          `${this.state.opponent_guess} was in ${guess}`
        );
        this.props.navigation.navigate("Login", {});
      } else {
        this.my_channel.trigger("client-opponent-won", {
          winner: this.username,
          reason: `${guess} wasn't in ${this.state.opponent_guess}`
        });
        Alert.alert(
          `You lost`,
          `${guess} wasn't in ${this.state.opponent_guess}`
        );
        this.props.navigation.navigate("Login", {});
      }
    } else {
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
    }
  };

  handleChallengePrevious = async () => {
    if (this.state.guessType === "actor") {
      const movieId = await movieApi.getMovieId(this.state.opponent_guess);
      const isInMovie = await movieApi.isActorInMovie(this.state.my_guess, movieId);
      if (isInMovie) {
        this.my_channel.trigger("client-opponent-won", {
          winner: this.opponent,
          reason: `Challenge lost! ${this.state.my_guess} was in ${this.state.opponent_guess}`
        });
        Alert.alert(
          `You lost`,
          `${this.state.my_guess} was in ${this.state.opponent_guess}`
        );
      } else {
        this.my_channel.trigger("client-opponent-won", {
          winner: this.username,
          reason: `${this.state.my_guess} wasn't in ${this.state.opponent_guess}`
        });
        Alert.alert(
          `You won!`,
          `${this.state.my_guess} wasn't in ${this.state.opponent_guess}`
        );
      }
    } else {
      const movieId = await movieApi.getMovieId(this.state.my_guess);
      const isInMovie = await movieApi.isActorInMovie(this.state.opponent_guess, movieId);
      if (isInMovie) {
        this.my_channel.trigger("client-opponent-won", {
          winner: this.opponent,
          reason: `Challenge lost! ${this.state.opponent_guess} was in ${this.state.my_guess}`
        });
        Alert.alert(
          `You lost`,
          `${this.state.opponent_guess} was in ${this.state.my_guess}`
        );
      } else {
        this.my_channel.trigger("client-opponent-won", {
          winner: this.username,
          reason: `${this.state.opponent_guess} wasn't in ${this.state.my_guess}`
        });
        Alert.alert(
          `You won!`,
          `${this.state.opponent_guess} wasn't in ${this.state.my_guess}`
        );
      }
    }
    this.props.navigation.navigate("Login", {});
  }

  handleChallengeNext = () => {
    const turn = this.state.turn === this.username ? this.opponent : this.username;
    this.setState({
      turn: turn,
      my_guess: this.state.my_guess,
      challenge: true
    });
    this.my_channel.trigger("client-opponent-guessed", {
      turn: turn,
      guessType: this.state.guessType,
      guess: this.state.opponent_guess,
      isChallenge: true
    })
  }

  resetGame = () => {
    this.setState({ isReadyToPlay: false });
    this.props.navigation.navigate("Login", {});
  };

  render() {
    console.log(`${this.username ? this.username : 'Initial'} state: ${JSON.stringify(this.state)}`)
    return (
      <KeyboardAvoidingView style={styles.container} behavior="padding" enabled>
        <GameStatus {...this.state} player={this.username} opponent={this.opponent} handleTimeUp={() => this.handleGameOver()}/>
        {this.state.isReadyToPlay && this.state.turn === this.username &&
          <Guess
            restart={this.restart}
            random={this.random}
            handleGuess={guess => this.handleGuessSubmit(guess)}
            guessType={this.state.guessType}
            previousGuess={this.state.opponent_guess}
            currentGuess={this.state.my_guess}
            challenge={this.state.challenge}
            giveUp={() => this.handleGameOver()}
            handleChallengePrevious={() => this.handleChallengePrevious()}
            handleChallengeNext={() => this.handleChallengeNext()} /> }
      </KeyboardAvoidingView>
    );
  }
}
