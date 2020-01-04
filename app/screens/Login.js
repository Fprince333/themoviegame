import React from "react";
import {
  View,
  KeyboardAvoidingView,
  TextInput,
  Alert,
  ActivityIndicator
} from "react-native";
import { Text, Button } from 'react-native-elements';
import Icon from 'react-native-vector-icons/FontAwesome';

import Pusher from "pusher-js/react-native";

export default class Login extends React.Component {
  static navigationOptions = {
    header: null
  };

  state = {
    username: "",
    enteredGame: false
  };

  constructor(props) {
    super(props);
    this.pusher = null;
    this.myChannel = null;
    this.opponentChannel = null;
  }

  render() {
    return (
      <KeyboardAvoidingView style={styles.container} behavior="padding" enabled keyboardVerticalOffset={-200} >
        <View style={styles.topContent}>
          <Text h2 h2Style={{color: '#FFF', marginBottom: 30 }}>The Movie Game</Text>
          <Icon name="film" color="#FFF" size={75} />
        </View>

        <View style={styles.mainContent}>

          {!this.state.enteredGame && (
            <React.Fragment>
              <Text style={styles.label}>Enter Username</Text>
              <TextInput
                ref={component => this._textInput = component}
                style={styles.text_field}
                onChangeText={username => {
                  this.setState({ username });
                }}
                value={this.state.username}
                selectionColor={'#FFF'}
                onSubmitEditing={this.enterGame}
                returnKeyType='go'
            />
            </React.Fragment>
          )}

          {this.state.enteredGame && (
            <React.Fragment>
              <ActivityIndicator size="large" color="#FFF" />
              <Text style={styles.label}>Waiting For Opponent</Text>
             </React.Fragment>
          )}
        </View>
      </KeyboardAvoidingView>
    );
  }

  enterGame = async () => {
    this._textInput.blur();
    const myUsername = this.state.username;

    if (myUsername) {
      this.setState({
        enteredGame: true
      });
      this.pusher = new Pusher("f9eaa640678326ebe543", {
        authEndpoint: "https://the-movie-game.herokuapp.com/pusher/auth",
        cluster: "us2",
        encrypted: true,
        auth: {
          params: { username: myUsername }
        }
      });

      this.myChannel = this.pusher.subscribe(`private-user-${myUsername}`);
      this.myChannel.bind("pusher:subscription_error", status => {
        this.myChannel.unbind();
        this.pusher.unsubscribe(`private-user-${myUsername}`)
        if (status === 406) {
          Alert.alert(
            "Error",
            "Your opponent is using that username. Please pick another."
          );
        } else {
          Alert.alert(
            "Error",
            "A subscription error occurred. Please try again."
          );
        }

      });

      this.myChannel.bind("pusher:subscription_succeeded", () => {
        console.log("subscription ok");
        this.myChannel.bind("opponent-found", data => {
          console.log("opponent found: ", data);
          const opponentUsername =
          myUsername == data.player_one ? data.player_two : data.player_one;

          const isPlayerOne = myUsername == data.player_one ? true : false;
          Alert.alert("Opponent found!", `${opponentUsername} will take you on!`);
          this.opponentChannel = this.pusher.subscribe(`private-user-${opponentUsername}`)
          this.opponentChannel.bind("pusher:subscription_error", data => {
            console.log("Error subscribing to opponent's channel: ", data);
          });
          this.opponentChannel.bind("pusher:subscription_succeeded", () => {
            this.props.navigation.navigate("Game", {
              pusher: this.pusher,
              isPlayerOne: isPlayerOne,
              myUsername: myUsername,
              myChannel: this.myChannel,
              opponentUsername: opponentUsername,
              opponentChannel: this.opponentChannel
            });
          });

          this.setState({
            enteredGame: false,
            username: ""
          });

        });
      });
    }
  };
}

const styles = {
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#2089dc"
  },
  topContent: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    marginTop: 50
  },
  mainContent: {
    flex: 1,
    justifyContent: "flex-start",
    marginBottom: 200
  },
  label: {
    marginTop: 15,
    marginBottom: 5,
    fontSize: 15,
    fontWeight: "bold",
    color: "#FFF"
  },
  text_field: {
    width: 200,
    height: 40,
    borderColor: "#FFF",
    borderWidth: 1,
    padding: 10,
    marginBottom: 10,
    color: '#FFF'
  }
};
