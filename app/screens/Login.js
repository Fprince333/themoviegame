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

import formatChannelName from "../helpers/formatChannelName";

export default class Login extends React.Component {
  static navigationOptions = {
    header: null
  };

  state = {
    username: "",
    is_loading: false
  };

  constructor(props) {
    super(props);
    this.pusher = null;
    this.my_channel = null;
  }

  render() {
    return (
      <KeyboardAvoidingView style={styles.container} behavior="padding" enabled keyboardVerticalOffset={-200} >
        <View style={styles.topContent}>
          <Text h2 h2Style={{color: '#FFF', marginBottom: 30 }}>The Movie Game</Text>
          <Icon name="film" color="#FFF" size={75} />
        </View>

        <View style={styles.mainContent}>

          {!this.state.is_loading && (
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
                onSubmitEditing={this.login}
                returnKeyType='go'
            />
            </React.Fragment>
          )}

          {this.state.is_loading && (
            <React.Fragment>
              <ActivityIndicator size="large" color="#FFF" />
              <Text style={styles.label}>Waiting For Opponent</Text>
             </React.Fragment>
          )}
        </View>
      </KeyboardAvoidingView>
    );
  }

  login = () => {
    this._textInput.blur();
    let username = this.state.username;

    if (username) {
      this.setState({
        is_loading: true
      });

      this.pusher = new Pusher("f9eaa640678326ebe543", {
        authEndpoint: "https://the-movie-game.herokuapp.com/pusher/auth",
        cluster: "us2",
        encrypted: true,
        auth: {
          params: { username: username }
        }
      });

      this.my_channel = this.pusher.subscribe(`private-user-${formatChannelName(username)}`);
      this.my_channel.bind("pusher:subscription_error", status => {
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
        this.setState({
          is_loading: false,
          username: ""
        });

      });

      this.my_channel.bind("pusher:subscription_succeeded", data => {

        this.my_channel.bind("opponent-found", data => {

          let opponent =
            username == data.player_one ? data.player_two : data.player_one;

          let starter = data.player_two;

          this.setState({
            is_loading: false,
            username: ""
          });

          this.props.navigation.navigate("Game", {
            pusher: this.pusher,
            username: username,
            opponent: opponent,
            starter: starter,
            my_channel: this.my_channel
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
