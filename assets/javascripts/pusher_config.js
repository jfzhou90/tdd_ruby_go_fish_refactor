var pusher = new Pusher('d99443f440ef4328b615', {
  cluster: 'us2',
  forceTLS: true
});

var channel = pusher.subscribe('my-channel');

channel.bind('my-event', function(data) {
  window.location.reload();
});

console.log('Pusher is running!')
