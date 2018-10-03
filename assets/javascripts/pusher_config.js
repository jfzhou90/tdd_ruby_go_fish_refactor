var pusher = new Pusher('d99443f440ef4328b615', {
  cluster: 'us2',
  forceTLS: true
});

console.log("Here's the game id:" + game_id)
var channel = pusher.subscribe(game_id);

channel.bind('refresh', function(data) {
  window.location.reload();
});

console.log('Pusher is running!')
