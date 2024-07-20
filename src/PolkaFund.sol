// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

enum FundState {
    OPEN_TO_INVESTORS,
    TRADING,
    CLOSED
}

contract PolkaFund {
    FundState public state;
}
