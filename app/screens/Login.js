import React from "react";
import {
  View,
  Text,
  TextInput,
  Button,
  Alert,
  ActivityIndicator
} from "react-native";

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
      <View style={styles.container}>
        <View style={styles.topContent}>
          <Text style={styles.bigText}>The Movie Game</Text>
        </View>

        <View style={styles.mainContent}>
          <Text style={styles.label}>Username</Text>
          <TextInput
            style={styles.text_field}
            onChangeText={username => {
              this.setState({ username });
            }}
            value={this.state.username}
            placeholder="Enter your username"
          />

          {!this.state.is_loading && (
            <Button onPress={this.login} title="Enter" color="#0064e1" />
          )}

          {this.state.is_loading && (
            <ActivityIndicator size="large" color="#0000ff" />
          )}
        </View>
      </View>
    );
  }

  login = () => {
    let username = this.state.username;

    if (username) {
      this.setState({
        is_loading: true
      });

      this.pusher = new Pusher("f9eaa640678326ebe543", {
        authEndpoint: "https://dd268553.ngrok.io/pusher/auth",
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
        console.log("subscription ok: ", data);

        this.my_channel.bind("opponent-found", data => {
          console.log("opponent found: ", data);

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
