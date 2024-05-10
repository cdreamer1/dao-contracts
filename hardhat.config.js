/** @type import('hardhat/config').HardhatUserConfig */
require('dotenv').config();
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-truffle4");

const { 
  POLYGON_API_URL, 
  AMOY_API_URL, 
  METAMASK_PRIVATE_KEY,
  POLYGONSCAN_API_KEY
} = process.env;

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      viaIR: true,
    }
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337
    },
    polygon: {
      url: POLYGON_API_URL,
      chainId: 137,
      accounts: [`0x${METAMASK_PRIVATE_KEY}`]
    },
    amoy: {
      url: AMOY_API_URL,
      chainId: 80002,
      accounts: [`0x${METAMASK_PRIVATE_KEY}`]
    }
  },
  sourcify: {
    enabled: false
  },
  etherscan: {
    apiKey: POLYGONSCAN_API_KEY,
    customChains: [
      {
        network: "Polygon Amoy",
        chainId: 80002,
        urls: {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: 'https://amoy.polygonscan.com'
        }
      }
    ]
  },
};
