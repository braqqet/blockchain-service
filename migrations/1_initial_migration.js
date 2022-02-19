const Migrations = artifacts.require("Migrations");
const FractionalAsset = artifacts.require("FractionalAsset");


module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(FractionalAsset);
};
