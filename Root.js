import React from 'react';
import { createAppContainer, createStackNavigator } from 'react-navigation';
import LoginScreen from './app/screens/Login';
import GameScreen from './app/screens/Game';

console.ignoredYellowBox = ["Setting a timer"];

const AppNavigator = createStackNavigator(
  {
    Login: LoginScreen,
    Game: GameScreen
  },
  {
    initialRouteName: "Login"
  }
);

const AppContainer = createAppContainer(AppNavigator);

export default AppContainer;
