const express = require('express');
const bodyParser = require('body-parser');
const Pusher = require('pusher');
const app = express();

let users = {};
let currentUser = {};

let pusher = new Pusher({
  appId: 'PUSHER_APP_ID',
  key: 'PUSHER_APP_KEY',
  secret: 'PUSHER_APP_SECRET',
  cluster: 'PUSHER_APP_CLUSTER'
});

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

/// Generate random ID
function generate_random_id() {
  let S4 = () => (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
  return S4() + S4() + '-' + S4() + '-' + S4() + '-' + S4() + '-' + S4() + S4() + S4();
}

/// Create a new user and set as the `currentUser`
app.post('/users', (req, res) => {
  const name = req.body.name;
  const matchedUsers = Object.keys(users).filter(id => users[id].name === name);

  if (matchedUsers.length === 0) {
    const id = generate_random_id();
    users[id] = currentUser = { id, name };
  } else {
    currentUser = users[matchedUsers[0]];
  }

  res.json({ currentUser, users });
});

/// Authenticate presence channel
app.post('/pusher/auth/presence', (req, res) => {
  let socketId = req.body.socket_id;
  let channel = req.body.channel_name;
  let presenceData = {
    user_id: currentUser.id,
    user_info: { name: currentUser.name }
  };
  let auth = pusher.authenticate(socketId, channel, presenceData);
  res.send(auth);
});

app.listen(process.env.PORT || 5000);
