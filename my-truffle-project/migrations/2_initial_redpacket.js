const Redpacket = artifacts.require("Redpacket");

module.exports = function (deployer) {
  deployer.deploy(Redpacket);
};