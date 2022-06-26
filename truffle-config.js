require('dotenv').config()
const HDWalletProvider = require('@truffle/hdwallet-provider')

module.exports = {
  // Uncommenting the defaults below
  // provides for an easier quick-start with Ganache.
  // You can also follow this format for other networks.
  // See details at: https://trufflesuite.com/docs/truffle/reference/configuration
  // on how to specify configuration options!
  //
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    },
    ropsten: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC, `https://ropsten.infura.io/v3/${process.env.INFURA_KEY}`)
      },
      network_id: 3
    },
    cronos: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC, `https://evm-t3.cronos.org/`)
      },
      network_id: "*"
    },
    polygon_mumbai: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC, 'https://matic-mumbai.chainstacklabs.com')
      },
      network_id: 80001,
      confirmations: 1
    },
    optimism_kovan: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC, `https://kovan.optimism.io`)
      },
      network_id: 69
    }
  },

  compilers: {
    solc: {
      version: "^0.8.0"
    }
  },
  plugins: ['truffle-plugin-verify'],
  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY
  }
}

