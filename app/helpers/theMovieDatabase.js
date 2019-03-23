const MOVIE_DB_URL = `https://api.themoviedb.org/3/`;
const MOVIE_DB_API_KEY = `5c9b27cf0af6b9ed8b5204fa273c43ff`;

export const movieApi = {
  getMovieId: async (name) => {
    return await fetch(
      `${MOVIE_DB_URL}search/movie?api_key=${MOVIE_DB_API_KEY}&query=${name}`
    ).then(response => response.json())
     .then(json => json.results[0].id)
  },
  getActorId: async (name) => {
    return await fetch(
      `${MOVIE_DB_URL}search/person?api_key=${MOVIE_DB_API_KEY}&query=${name}`
    ).then(response => response.json())
     .then(json => json.results[0].id)
  },
  isActorInMovie: async (name, movieId) => {
    const cast = await fetch(
      `${MOVIE_DB_URL}movie/${movieId}/credits?api_key=${MOVIE_DB_API_KEY}`
    ).then(response => response.json())
     .then(json => json.cast)
    return cast.filter(person => person.name === name).length;
  }
}
