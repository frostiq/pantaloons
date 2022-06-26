const Appraiser = artifacts.require("Appraiser");
const NFTLendingPool = artifacts.require("NFTLendingPool");

module.exports = async function(deployer) {
  const usdc = "0x9c3f0fc85ef9144412388e7e952eb505e2c4a10f"
  const appraiser = await Appraiser.deployed()
  // const appraiser = {address:"0x18654954752CbE0baC4EfD3fFAe4a8e2e66d7E2d"}
  await deployer.deploy(NFTLendingPool, usdc, appraiser.address);
}
