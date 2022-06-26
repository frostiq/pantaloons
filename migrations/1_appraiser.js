const Appraiser = artifacts.require("Appraiser");
const ERC20 = artifacts.require("ERC20");

module.exports = function(deployer) {
  deployer.deploy(Appraiser);
};
