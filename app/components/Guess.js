import React from "react";
import { View, TextInput } from "react-native";
import { Overlay, Button, Text } from 'react-native-elements';
import Icon from 'react-native-vector-icons/FontAwesome';

const styles = {
  mainContent: {
    flex: 1,
    justifyContent: 'flex-start',
    alignItems: 'center',
    textAlign: 'center',
    width: '100%'
  },
  modalContent: {
    flex: 1,
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  modalContentInner: {
    flex: 1,
    justifyContent: 'center',
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

  handlePrevious = () => {
    this.props.handleChallengePrevious();
    this.setState({showModal: false})
  }

  handleNext = () => {
    this.props.handleChallengeNext();
    this.setState({ showModal: false })
  }

  render() {
    return (
      <View>
        <Button
          buttonStyle={{ backgroundColor: '#2089dc' }}
          title={this.props.challenge ? `Give Up` : `Challenge`}
          titleStyle={{ color: '#FFF' }}
          onPress={this.props.challenge ? this.props.giveUp : this.renderChallengeModal}
        />
        <Overlay
          isVisible={this.state.showModal}
          onBackdropPress={() => this.setState({ showModal: false })}
          height="65%"
        >
          <React.Fragment>
            <Icon name='times-circle' size={24} color="#2089dc" onPress={() => this.setState({ showModal: false })} />
            <View style={styles.modalContent}>
              <View style={styles.modalContentInner}>
                {this.props.guessType === 'movie' && <Text h4>Was {this.props.previousGuess} in {this.props.currentGuess}?</Text>}
                {this.props.guessType === 'actor' && <Text h4>Was {this.props.currentGuess} in {this.props.previousGuess}?</Text>}
                <Button
                  buttonStyle={{ backgroundColor: '#2089dc', marginTop: 15 }}
                  title="Challenge Answer"
                  titleStyle={{ color: '#FFF' }}
                  onPress={this.handlePrevious}
                />
              </View>
              <View style={styles.modalContentInner}>
                {this.props.guessType === 'movie' && <Text h4>Make opponent name another movie {this.props.previousGuess} was in?</Text>}
                {this.props.guessType === 'actor' && <Text h4>Make opponent name another actor in {this.props.previousGuess}?</Text>}
                <Button
                  buttonStyle={{ backgroundColor: '#2089dc', marginTop: 15 }}
                  title="Challenge Opponent"
                  titleStyle={{ color: '#FFF' }}
                  onPress={this.handleNext}
                />
              </View>
            </View>
          </React.Fragment>
        </Overlay>
      </View>
    );
  }
}

const StartOver = props => {
  return (
    <View>
      <Button
        buttonStyle={{ backgroundColor: '#2089dc' }}
        title={props.previousGuess.length ? `Request New Movie` : `Request Random`}
        titleStyle={{ color: '#FFF' }}
        onPress={props.previousGuess.length ? props.handleRestart : props.handleRandom}
      />
    </View>
  );
}

const Guess = props => {
  return (
    <View style={styles.mainContent}>
      <GuessText handleGuess={props.handleGuess}/>
      { props.previousGuess.length && props.currentGuess.length ? <Challenge {...props} /> : <StartOver handleRandom={props.random} handleRestart={props.restart} {...props}/> }
    </View>
  );
}

export default Guess;
