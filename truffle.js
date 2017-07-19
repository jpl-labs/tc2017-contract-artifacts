// Allows us to use ES6 in our migrations and tests.
require('babel-register')

module.exports = {
  networks: {
    development: {
      host: 'tc20175xj.eastus.cloudapp.azure.com',
      port: 8545,
      network_id: '*' // Match any network id
    }
  }
}
