const Zinko = require('zinko');

class Home extends Zinko {

  GET_root(req, res) {
	res.end('Hello World');
  }

}

module.exports = Home;
