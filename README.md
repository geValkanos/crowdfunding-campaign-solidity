# Crowdfunding Campaign with an ERC20 token.
Our campaign is written in solidity and it's based on the following rules.
 - Funds take the form of a custom ERC20 token
 - Crowdfunded projects have a funding goal
 - When a funding goal is not met, customers are be able to get a refund of their pledged funds
 - dApps using the contract can observe state changes in transaction logs
 - Contract is upgradeable

## Setup the project locally

### Install the virtual environment
- nodeenv --node=18.12.1 --prebuilt env

### Activate the virtual environment
- source env/bin/activate

### Install the packages
- npm install

### Setup the `.env`, based on `.env.template`. You can use `.env.testing` directly as sample.
- cp .env.testing .env

## Run tests

### Use .env.testing for .env
- cp .env.testing .env

### Execute the tests
- npx truffle test

## Debug on ganache

### Open a second terminal and run ganache.
- npx ganache

### Migrate on ganache
- npx truffle migrate --network ganache

## Run ganache console
- npx truffle console --network ganache
