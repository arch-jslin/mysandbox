var rl  = require('readline')
var cli = rl.createInterface(process.stdin, process.stdout)
cli.setPrompt("Test> ");

cli.on('line', function(line) {
  console.log(line);
  cli.prompt();
});

cli.prompt();
