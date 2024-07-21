## PolkaFund


**PolkaFund is a POC project for token investment management on the Polkadot's Acala parachain**



## Presentation
https://canva.com/design/DAGLUJN9Dc4/k0JHCX-Ua0rxyETTw5Mefg/view

## Short Description
PolkaFund is an dApp that enables secure and trustless token investment management using Acala Swap. 


## Full Description
The objective of investment management firms is to provide returns on funds deposited by investors. The investors benefit from the returns, which aim to beat keeping your money in a deposit account, and the asset managers benefit from a performance-based commission for providing this service.
In TradFi this operates on a model of trust; investors trust that the asset managers do not run away with their funds.

PolkaFunds makes investment management trustless through smart contract logic, by guaranteeing:
- token security (tokens are locked in the smart contract, to prevent managers running away with funds)
- returning of investments with profits to investors after a set period
- manager performance fees immutably set in advance



## Technical Description
This project is made possible by the following EVM+ feature of Acala:
- Native DEX: providing investment managers have access to the liquidity of the native DEX Acala Swap
- On-Chain Scheduler: providing guaranteed return of invested funds with profits after a set period

This project has been setup using the Foundry project template, and used the following libraries:
- Acala Predeploys (https://github.com/AcalaNetwork/predeploy-contracts): Pre-deployed DEX and Scheduler contracts
- OpenZeppelin (https://github.com/openzeppelin/openzeppelin-contracts): Ownerable contract for access management
- Forge Std (https://github.com/foundry-rs/forge-std): Soldiity unit testing tools


### Testnet Deployment
This smart contract has been deployed on the Acala testnet:
...



### Run unit tests


```shell
$ forge test
```
