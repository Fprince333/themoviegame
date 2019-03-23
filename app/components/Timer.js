import React from "react";
import { StyleSheet, View } from "react-native";
import { Text } from 'react-native-elements';
import CountDown from 'react-native-countdown-component';

export default class Timer extends React.Component {
  render() {
    return (
      <View style={styles.container}>
        <CountDown
          until={120}
          timeToShow={['M', 'S']}
          digitStyle={{ backgroundColor: '#FFF' }}
          onFinish={this.props.handleTimeUp}
          size={30}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "flex-start"
  }
});
