const NFTLendingPool = artifacts.require("NFTLendingPool");

module.exports = function(deployer) {
  deployer.deploy(NFTLendingPool);
};
