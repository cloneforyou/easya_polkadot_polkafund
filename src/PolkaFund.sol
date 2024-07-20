// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

enum FundState {
    OPEN_TO_INVESTORS,
    TRADING,
    CLOSED
}

contract PolkaFund {
    FundState public state;
    address payable public immutable manager;
    address payable[] public investors;
    mapping(address => uint256) public investorDeposits;
    uint256 public totalDeposited = 0;
    uint8 public performanceFeePercent;

    function returnInvestmentsWithProfit() public {
        // ensure this is only called by the sceduler
        require(msg.sender == address(this), "Must be closed by Sceduler");

        state = FundState.CLOSED;

        // check if there has been any profit
        if (address(this).balance > totalDeposited) {
            // calculate performance fee
            uint256 profit = address(this).balance - totalDeposited;
            uint256 totalPerformanceFee = (profit * performanceFeePercent) / 100;
            manager.transfer(totalPerformanceFee);
        }

        // transfer remaining balance to investors
        uint256 remainingBalance = address(this).balance;
        for (uint256 i = 0; i < investors.length; i++) {
            address payable investorAddr = investors[i];
            uint256 depositAmt = investorDeposits[investorAddr];
            if (depositAmt > 0) {
                uint256 percentage = (depositAmt * 100) / totalDeposited;
                uint256 fractionToPay = (remainingBalance * percentage) / 100;
                investorAddr.transfer(fractionToPay);
            }
        }
    }
}
