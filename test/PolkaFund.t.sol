// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PolkaFund} from "../src/PolkaFund.sol";

contract PolkaFundTest is Test {
    function test_one_investor() public {
        // Arrange
        address manager = makeAddr("manager");
        address investor = makeAddr("investor");
        vm.deal(investor, 200);

        PolkaFund fund = new PolkaFund(manager, 20);

        // Act & Assert
        uint256 amt = fund.totalDeposited();
        assertEq(amt, 0);

        vm.prank(investor, investor);
        fund.depositInvestment{value: 200}();
        assertEq(fund.investorDeposits(investor), 200);

        amt = fund.totalDeposited();
        assertEq(amt, 200);

        vm.prank(address(fund), address(fund));
        fund.returnInvestmentsWithProfit();
        assertEq(investor.balance, 200);
    }

    function test_three_investors() public {
        // Arrange
        address manager = makeAddr("manager");
        address investor1 = makeAddr("investor1");
        vm.deal(investor1, 33);
        address investor2 = makeAddr("investor2");
        vm.deal(investor2, 33);
        address investor3 = makeAddr("investo3");
        vm.deal(investor3, 34);

        PolkaFund fund = new PolkaFund(manager, 20);

        // Act
        // Assert
        vm.prank(investor1, investor1);
        fund.depositInvestment{value: 33}();
        vm.prank(investor2, investor2);
        fund.depositInvestment{value: 33}();
        vm.prank(investor3, investor3);
        fund.depositInvestment{value: 34}();

        uint256 totalDeposited = fund.totalDeposited();
        assertEq(totalDeposited, 100);

        assertEq(fund.investorDeposits(investor1), 33);
        assertEq(fund.investorDeposits(investor2), 33);
        assertEq(fund.investorDeposits(investor3), 34);

        vm.prank(address(fund), address(fund));
        fund.returnInvestmentsWithProfit();

        assertEq(investor1.balance, 33);
        assertEq(investor2.balance, 33);
        assertEq(investor3.balance, 34);
    }

    function test_three_investors_profit() public {
        // Arrange
        address manager = makeAddr("manager");
        address investor1 = makeAddr("investor1");
        vm.deal(investor1, 33);
        address investor2 = makeAddr("investor2");
        vm.deal(investor2, 33);
        address investor3 = makeAddr("investo3");
        vm.deal(investor3, 34);

        PolkaFund fund = new PolkaFund(manager, 20);

        // Act
        // Assert
        vm.prank(investor1, investor1);
        fund.depositInvestment{value: 33}();
        vm.prank(investor2, investor2);
        fund.depositInvestment{value: 33}();
        vm.prank(investor3, investor3);
        fund.depositInvestment{value: 34}();

        uint256 totalDeposited = fund.totalDeposited();
        assertEq(totalDeposited, 100);

        // simulate profits
        vm.deal(address(fund), 150);

        vm.prank(address(fund), address(fund));
        fund.returnInvestmentsWithProfit();

        assertEq(fund.investorDeposits(investor1), 33);
        assertEq(fund.investorDeposits(investor2), 33);
        assertEq(fund.investorDeposits(investor3), 34);

        assertEq(investor1.balance, 46);
        assertEq(investor2.balance, 46);
        assertEq(investor3.balance, 47);
    }
}
