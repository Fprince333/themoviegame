import React from "react";
import { View, TextInput } from "react-native";
import { Overlay, Button, Text } from 'react-native-elements';
import Icon from 'react-native-vector-icons/FontAwesome';

const styles = {
  mainContent: {
    flex: 1,
    justifyContent: 'top',
    alignItems: 'center',
    textAlign: 'center',
    width: '100%'
  },
  modalContent: {
    flex: 1,
    justifyContent: 'space-around',
    alignItems: 'center'
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
    marginTop: 15,
    marginBottom: 10,
    textAlign: "center"
  }
};

class GuessText extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      guess: ""
     }
  }
  render() {
    return (<TextInput
      style={styles.text_field}
      onChangeText={guess => {
        this.setState({ guess: guess });
      }}
      value={this.state.guess}
      returnKeyType='done'
      onSubmitEditing={() => this.props.handleGuess(this.state.guess)}
    /> );
  }
}

class Challenge extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      showModal: false
    }
  }

  renderChallengeModal = () => {
    this.setState({ showModal: true })
  }

  render() {
    return (
      <View>
        <Button
          buttonStyle={{ backgroundColor: '#2089dc' }}
          title="Challenge"
          titleStyle={{ color: '#FFF' }}
          onPress={this.renderChallengeModal}
        />
        <Overlay
          isVisible={this.state.showModal}
          onBackdropPress={() => this.setState({ showModal: false })}
          height="35%"
        >
          <React.Fragment>
            <Icon name='times-circle' size={24} color="#2089dc" onPress={() => this.setState({ showModal: false })} />
            <View style={styles.modalContent}>
              {this.props.guessType === 'movie' && <Text h4>Was {this.props.previousGuess} in {this.props.currentGuess}?</Text>}
              {this.props.guessType === 'actor' && <Text h4>Was {this.props.currentGuess} in {this.props.previousGuess}?</Text>}
              <Button
                buttonStyle={{ backgroundColor: '#2089dc' }}
                title="Challenge Answer"
                titleStyle={{ color: '#FFF' }}
                onPress={this.props.handleChallengePrevious}
              />
              <Button
                buttonStyle={{ backgroundColor: '#2089dc' }}
                title="Challenge Opponent"
                titleStyle={{ color: '#FFF' }}
                onPress={this.props.handleChallengeNext}
              />
            </View>
          </React.Fragment>
        </Overlay>
      </View>
    );
  }
}

const Guess = props => {
  return (
    <View style={styles.mainContent}>
      <GuessText handleGuess={props.handleGuess}/>
      {props.previousGuess.length ? <Challenge {...props} /> : null }
    </View>
  );
}

export default Guess;
