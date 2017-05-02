## README

This was a passion project of mine that is quite hard, but very functional. 

### Rules

- You are prompted to name an actor or actress in a movie. 
- Guess right and the game keeps going. 
- Guess wrong and you lose. 
- Score higher than 5 to be elligible for the leaderboards. 

### Local installation

```
bundle exec rake db:create 
bundle exec rake:db migrate
rails s 
```

In a new terminal window

```
npm install
npm run watch
```

### Deployment

The leaderboards are hosted on [Heroku](https://the-movie-game.herokuapp.com/)
The client is hosted on Netlify and every push to master triggers a new build of the site

### Gotchas

Stub out the pg Gem before pushing to master. Only unstub it when pushing to production. 
