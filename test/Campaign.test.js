const FakeToken = artifacts.require("FakeToken");
const TokenSale = artifacts.require("TokenSale.sol");
const Campaign = artifacts.require("Campaign.sol");

const { expect, assert } = require("chai");
const truffleAssert = require('truffle-assertions');

const chai = require("chai");
const chaiBN = require("chai-bn")(web3.utils.BN);
const chaiAsPromised = require("chai-as-promised");

chai.use(chaiBN);
chai.use(chaiAsPromised);

const donate = async (instance, campaignInstance, tokenSaleInstance, contributor, tokensBought, tokensDonated) => {
    // Purchase some tokens
    await tokenSaleInstance.purchase({from: contributor, value: web3.utils.toWei(`${tokensBought}`, "ether")});

    // Set the allowance for the campaign contract
    await instance.approve(campaignInstance.address, tokensDonated, {from: contributor});

    const contribution = await campaignInstance.addFunds(tokensDonated, {from: contributor});

    truffleAssert.eventEmitted(contribution, 'FundsSent', (args) => {
        expect(args.amount).to.be.a.bignumber.equal(new web3.utils.BN(tokensDonated));
        return args.user == contributor && !args.isRefund;
    });

    return contribution;
}

contract("Campaign Tests", (accounts) => {

    let instance, campaignInstance, tokenSaleInstance;

    before(async () => {
        instance = await FakeToken.deployed();
        campaignInstance = await Campaign.deployed();
        tokenSaleInstance = await TokenSale.deployed();
    })

    it("Add funds while the goal is not reached", async () => {
        // Account 2 buys 10 tokens, donates 7
        await donate(instance, campaignInstance, tokenSaleInstance, accounts[2], 10, 7);
        expect(instance.balanceOf(accounts[2])).to.eventually.be.a.bignumber.equal(new web3.utils.BN(3));
        expect(instance.balanceOf(Campaign.address)).to.eventually.be.a.bignumber.equal(new web3.utils.BN(7));

        // Account 3 buys 10 tokens, donates 5
        await donate(instance, campaignInstance, tokenSaleInstance, accounts[3], 10, 5);
        expect(instance.balanceOf(accounts[3])).to.eventually.be.a.bignumber.equal(new web3.utils.BN(5));
        return expect(instance.balanceOf(Campaign.address)).to.eventually.be.a.bignumber.equal(new web3.utils.BN(12));
    })

    it("Refund while the campaign is still active", async () => {
        // Account 4 buys 3 tokens, donates 2
        await donate(instance, campaignInstance, tokenSaleInstance, accounts[4], 3, 2);
        expect(instance.balanceOf(accounts[4])).to.eventually.be.a.bignumber.equal(new web3.utils.BN(1));
        
        // Account 4 buys another 3 tokens, donates 2.
        await donate(instance, campaignInstance, tokenSaleInstance, accounts[4], 3, 2);
        expect(instance.balanceOf(accounts[4])).to.eventually.be.a.bignumber.equal(new web3.utils.BN(2));

        // Account 4 demands refund.
        const contribution = await campaignInstance.refund({from: accounts[4]});

        truffleAssert.eventEmitted(contribution, 'FundsSent', (args) => {
            expect(args.amount).to.be.a.bignumber.equal(new web3.utils.BN(4));
            return args.user == accounts[4] && args.isRefund;
        });
        expect(instance.balanceOf(accounts[4])).to.eventually.be.a.bignumber.equal(new web3.utils.BN(6));
        return expect(instance.balanceOf(Campaign.address)).to.eventually.be.a.bignumber.equal(new web3.utils.BN(12));
    })

    it("A user completes the goal", async() => {
        // Account 5 buys 8 tokens, donates 8
        await tokenSaleInstance.purchase({from: accounts[5], value: web3.utils.toWei("8", "ether")});
        await instance.approve(campaignInstance.address, 8, {from: accounts[5]});

        const contribution = await campaignInstance.addFunds(8, {from: accounts[5]});
        expect(instance.balanceOf(accounts[5])).to.eventually.be.a.bignumber.equal(new web3.utils.BN(0));
        expect(instance.balanceOf(Campaign.address)).to.eventually.be.a.bignumber.equal(new web3.utils.BN(20));
        truffleAssert.eventEmitted(contribution, 'Closed', (args) => {
            expect(instance.balanceOf(Campaign.address)).to.eventually.be.a.bignumber.equal(new web3.utils.BN(args.goalAmount));
            return args.goalAmount.toString() == args.totalGathered.toString();
        });
    })

    it("A user funds refunds on completed goal, but fails", async() => {
        // Account 5 asks to refund his donation.
        await truffleAssert.reverts(campaignInstance.refund({from: accounts[5]}), "The goal is completed, no refunds allowed");  

        // Account 4 tries to donate on the completed goal.
        await truffleAssert.reverts(campaignInstance.addFunds(1, {from: accounts[4]}), "The goal has already been achieved"); 
    })

})


