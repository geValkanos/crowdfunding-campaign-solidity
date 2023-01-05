const FakeToken = artifacts.require("FakeToken.sol");
const TokenSale = artifacts.require("TokenSale.sol");
const Campaign = artifacts.require("Campaign.sol");

require("dotenv").config({path: "../.env"});

module.exports = async (deployer) => {
    if (!process.env.TOKEN_ADDRESS) {
        console.log('AAA');
        await deployer.deploy(FakeToken);
        await deployer.deploy(TokenSale, FakeToken.address);    
        let instance = await FakeToken.deployed();
        await instance.mintAndSendToTokenSale(process.env.INITIAL_SUPPLY, TokenSale.address);
    }
    console.log(process.env.TOKEN_ADDRESS || FakeToken.address);
    await deployer.deploy(Campaign, process.env.CAMPAIGN_GOAL, process.env.TOKEN_ADDRESS || FakeToken.address);
    
}