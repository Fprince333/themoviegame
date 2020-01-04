import React, { PureComponent } from "react";
import { KeyboardAvoidingView, Alert } from "react-native";
import { Button } from 'react-native-elements';
import Icon from 'react-native-vector-icons/FontAwesome';

import Guess from "../components/Guess";
import GameStatus from '../components/GameStatus';

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

export default class Game extends PureComponent {
  static navigationOptions = ({ navigation }) => {
    return {
      headerTitle: `TMG: ${navigation.getParam("myUsername")} vs ${navigation.getParam("opponentUsername")}`,
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
          navigation.getParam("myChannel").trigger("client-opponent-won", {
            winner: "You",
            reason: "Your opponent exited the game."
          });
          navigation.navigate("Login", {})
        }}
      />
    };
  };

  state = {
    turn: null,
    myGuess: '',
    opponentGuess: '',
    guessType: 'movie',
    isReadyToPlay: false,
    challenge: false,
    usedActors: [],
    usedMovies: []
  }

  constructor(props) {
    super(props);
    const { navigation } = this.props;
    
    this.pusher = navigation.getParam('pusher');
    this.myUsername = navigation.getParam('myUsername');
    this.opponentUsername = navigation.getParam('opponentUsername');

    this.myChannel = navigation.getParam('myChannel');
    this.opponentChannel = navigation.getParam('opponentChannel');
    this.isPlayerOne = navigation.getParam('isPlayerOne');

    this.opponentChannel.bind("client-opponent-guessed", data => {
      data.guessType === 'actor' ?
        this.setState({
          usedMovies: data.usedMovies,
          turn: data.turn,
          guessType: data.guessType,
          opponentGuess: data.guess,
          challenge: data.isChallenge }) :
        this.setState({
          usedActors: data.usedActors,
          turn: data.turn,
          guessType: data.guessType,
          opponentGuess: data.guess,
          challenge: data.isChallenge })
    });

      this.opponentChannel.bind("client-opponent-won", data => {
        Alert.alert(
          `${data.winner} won`,
          `${data.reason}`
        );
        this.setState({ isReadyToPlay: false });
        this.resetGame()
      });


    this.myChannel.bind('start-game', () => {
      Alert.alert('Game Start!', 'You may now navigate towards the black square.');
      this.setState({
        isReadyToPlay: true
      });
    });

  }

  componentDidMount() {
    this.setState({ turn: this.isPlayerOne ? this.myUsername : this.opponentUsername })
  }

  componentWillUnmount() {
    this.pusher.disconnect();
  }

  restart = () => {
    const turn = this.state.turn === this.myUsername ? this.opponentUsername : this.myUsername;
    const guessType = "movie";
    this.setState({
      turn: turn,
      guessType: guessType
    });
    this.myChannel.trigger("client-opponent-guessed", {
      turn: turn,
      guessType: guessType,
      guess: ""
    })

  }

  random = async () => {
    const turn = this.state.turn === this.myUsername ? this.opponentUsername : this.myUsername;
    const guessType = "actor";
    const usedMovies = this.state.usedMovies;
    let randomMovie = await movieApi.getRandomMovie();
    if (usedMovies.includes(randomMovie)) {
      randomMovie = await movieApi.getRandomMovie();
    }
    usedMovies.push(randomMovie);
    this.setState({
      turn: turn,
      guessType: guessType,
      myGuess: randomMovie,
      usedMovies: usedMovies
    });
    this.myChannel.trigger("client-opponent-guessed", {
      turn: turn,
      guessType: guessType,
      guess: randomMovie,
      usedMovies: usedMovies
    })
  }

  handleTimeUp = () => {
    this.myChannel.trigger("client-opponent-won", {
      winner: "You",
      reason: `${this.myUsername} ran out of time.`
    });
    Alert.alert(
      `You Lost`,
      `You ran out of time.`
    );
    this.resetGame();
  }

  handleGiveUp = () => {
    this.myChannel.trigger("client-opponent-won", {
      winner: "You",
      reason: `${this.myUsername} gave up`
    });
    Alert.alert(
      `You Lost`,
      `You quit`
    );
    this.resetGame();
  }

  handleGuessSubmit = async guess => {
    if (this.state.challenge && this.state.guessType === "actor") {
      const movieId = await movieApi.getMovieId(this.state.myGuess);
      const isInMovie = await movieApi.isActorInMovie(guess, movieId);
      if (isInMovie) {
        this.myChannel.trigger("client-opponent-won", {
          winner: this.opponent,
          reason: `${guess} was also in ${this.state.myGuess}`
        });
        Alert.alert(
          `You won!`,
          `${guess} was also in ${this.state.myGuess}`
        );
        this.resetGame()
      } else {
        this.myChannel.trigger("client-opponent-won", {
          winner: this.myUsername,
          reason: `${guess} wasn't in ${this.state.myGuess}`
        });
        Alert.alert(
          `You won!`,
          `${guess} wasn't in ${this.state.myGuess}`
        );
        this.resetGame()
      }
    } else if (this.state.challenge && this.state.guessType === "movie") {
      const movieId = await movieApi.getMovieId(guess);
      const isInMovie = await movieApi.isActorInMovie(this.state.opponentGuess, movieId);
      if (isInMovie) {
        this.myChannel.trigger("client-opponent-won", {
          winner: this.myUsername,
          reason: `${this.state.opponentGuess} was also in ${guess}`
        });
        Alert.alert(
          `You won!`,
          `${this.state.opponentGuess} was also in ${guess}`
        );
        this.resetGame()
      } else {
        this.myChannel.trigger("client-opponent-won", {
          winner: this.myUsername,
          reason: `${guess} wasn't in ${this.state.opponentGuess}`
        });
        Alert.alert(
          `You lost`,
          `${guess} wasn't in ${this.state.opponentGuess}`
        );
        this.resetGame()
      }
    } else {
      const turn = this.state.turn === this.myUsername ? this.opponentUsername : this.myUsername;
      const guessType = this.state.guessType === "movie" ? "actor" : "movie";
      let usedMovies = this.state.usedMovies;
      let usedActors = this.state.usedActors;
      if (this.state.guessType === "movie") {
        if (usedMovies.includes(guess)) {
          this.myChannel.trigger("client-opponent-won", {
            winner: this.opponentUsername,
            reason: `${guess} was already used.`
          });
          Alert.alert(
            `You lost`,
            `${guess} was already used.`
          );
          this.resetGame()
        } else {
          usedMovies.push(guess);
          this.setState({
            turn: turn,
            guessType: guessType,
            myGuess: guess,
            usedMovies: usedMovies
          });
          this.myChannel.trigger("client-opponent-guessed", {
            turn: turn,
            guessType: guessType,
            guess: guess,
            usedMovies: usedMovies
          })
        }
      } else {
        if (usedActors.includes(guess)) {
          this.myChannel.trigger("client-opponent-won", {
            winner: this.opponentUsername,
            reason: `${guess} was already used.`
          });
          Alert.alert(
            `You lost`,
            `${guess} was already used.`
          );
          this.myChannel.unbind();
          this.props.navigation.navigate("Login", { });
        } else {
          usedActors.push(guess);
          this.setState({
            turn: turn,
            guessType: guessType,
            myGuess: guess,
            usedActors: usedActors
          });
          this.myChannel.trigger("client-opponent-guessed", {
            turn: turn,
            guessType: guessType,
            guess: guess,
            usedActors: usedActors
          })
        }
      }
    }
  };

  handleChallengePrevious = async () => {
    if (this.state.guessType === "actor") {
      const movieId = await movieApi.getMovieId(this.state.opponentGuess);
      const isInMovie = await movieApi.isActorInMovie(this.state.myGuess, movieId);
      if (isInMovie) {
        this.myChannel.trigger("client-opponent-won", {
          winner: this.opponentUsername,
          reason: `Challenge lost! ${this.state.myGuess} was in ${this.state.opponentGuess}`
        });
        Alert.alert(
          `You lost`,
          `${this.state.myGuess} was in ${this.state.opponentGuess}`
        );
      } else {
        this.myChannel.trigger("client-opponent-won", {
          winner: this.myUsername,
          reason: `${this.state.myGuess} wasn't in ${this.state.opponentGuess}`
        });
        Alert.alert(
          `You won!`,
          `${this.state.myGuess} wasn't in ${this.state.opponentGuess}`
        );
      }
    } else {
      const movieId = await movieApi.getMovieId(this.state.myGuess);
      const isInMovie = await movieApi.isActorInMovie(this.state.opponentGuess, movieId);
      if (isInMovie) {
        this.myChannel.trigger("client-opponent-won", {
          winner: this.opponentUsername,
          reason: `Challenge lost! ${this.state.opponentGuess} was in ${this.state.myGuess}`
        });
        Alert.alert(
          `You lost`,
          `${this.state.opponentGuess} was in ${this.state.myGuess}`
        );
      } else {
        this.myChannel.trigger("client-opponent-won", {
          winner: this.myUsername,
          reason: `${this.state.opponentGuess} wasn't in ${this.state.myGuess}`
        });
        Alert.alert(
          `You won!`,
          `${this.state.opponentGuess} wasn't in ${this.state.myGuess}`
        );
      }
    }
    this.resetGame()
  }

  handleChallengeNext = () => {
    const turn = this.state.turn === this.myUsername ? this.opponentUsername : this.myUsername;
    this.setState({
      turn: turn,
      myGuess: this.state.myGuess,
      challenge: true
    });
    this.myChannel.trigger("client-opponent-guessed", {
      turn: turn,
      guessType: this.state.guessType,
      guess: this.state.opponentGuess,
      isChallenge: true
    })
  }

  resetGame = () => {
    this.myChannel.unbind();
    this.props.navigation.navigate("Login", { });
  };

  render() {
    return (
      <KeyboardAvoidingView style={styles.container} behavior="padding" enabled>
        <GameStatus {...this.state} player={this.myUsername} opponent={this.opponentUsername} handleTimeUp={() => this.handleTimeUp()}/>
        {this.state.isReadyToPlay && this.state.turn === this.myUsername &&
          <Guess
            restart={this.restart}
            random={this.random}
            handleGuess={guess => this.handleGuessSubmit(guess)}
            guessType={this.state.guessType}
            previousGuess={this.state.opponentGuess}
            currentGuess={this.state.myGuess}
            challenge={this.state.challenge}
            giveUp={() => this.handleGiveUp()}
            handleChallengePrevious={() => this.handleChallengePrevious()}
            handleChallengeNext={() => this.handleChallengeNext()} /> }
      </KeyboardAvoidingView>
    );
  }
}
