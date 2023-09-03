require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: "https://rinkeby.infura.io/v3/5cf4b03b1e6347e39ced124f8d5f8698",
      accounts: [0a2f7c20c19c0cd313a4957c2280496423fdccd82ad5ca4aa99bcb9792c7cf4e],
    },
    // Add more networks as needed
  },
};
