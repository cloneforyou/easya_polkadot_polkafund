// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Acala EVM+ precompiles
import {DEX, SCHEDULE} from "@acala-network/utils/Predeploy.sol";
import {IDEX} from "@acala-network/dex/IDEX.sol";
import {ISchedule} from "@acala-network/schedule/ISchedule.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

enum FundState {
    OPEN_TO_INVESTORS,
    TRADING,
    CLOSED
}

contract FundFactory {
    event FundCreated(address newAddress);

    function createAsManager(uint8 performanceFeePercent) external returns (PolkaFund) {
        return create(msg.sender, performanceFeePercent);
    }

    function create(address manager, uint8 performanceFeePercent) public returns (PolkaFund) {
        PolkaFund newFund = new PolkaFund(manager, performanceFeePercent);
        emit FundCreated(address(newFund));
        return newFund;
    }
}

contract PolkaFund is Ownable {
    FundState public state;
    address payable public immutable manager;
    address payable[] public investors;
    mapping(address => uint256) public investorDeposits;
    uint256 public totalDeposited = 0;
    uint8 public performanceFeePercent;

    ISchedule private constant scheduler = ISchedule(SCHEDULE);
    IDEX private constant dex = IDEX(DEX);

    uint256 public constant DELAY = 200_000; // ~1 month

    constructor(address _manager, uint8 _performanceFeePercent) Ownable(_manager) {
        require(_performanceFeePercent < 100, "Performance fee percentage must be less than 100%");
        state = FundState.OPEN_TO_INVESTORS;
        manager = payable(_manager);
        performanceFeePercent = _performanceFeePercent;
    }

    function startTrading() external onlyOwner {
        state = FundState.TRADING;

        // sehedule the return of funds after DELAY blocks
        scheduler.scheduleCall(
            address(this), 0, 100000, 100, DELAY, abi.encodeWithSignature("returnInvestmentsWithProfit()")
        );
    }

    /**
     * returns despoits + porfits (if made) to investors and pays performance fee to the manager
     */
    function returnInvestmentsWithProfit() public {
        // ensure this is only called by the sceduler
        require(msg.sender == address(this), "Must be called by Scheduler");

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

    modifier onlyOpenToInvesters() {
        require(state == FundState.OPEN_TO_INVESTORS, "This fund is not currently open to investors");
        _;
    }

    event Deposited(address investor, uint256 amt);

    /**
     * take deposits from investors
     */
    function depositInvestment() external payable onlyOpenToInvesters {
        investorDeposits[msg.sender] += msg.value;
        totalDeposited += msg.value;
        investors.push(payable(msg.sender));
        emit Deposited(msg.sender, msg.value);
    }

    // DEX trading and staking functions

    function swapWithExactSupply(address[] memory path, uint256 supplyAmount, uint256 minTargetAmount)
        public
        payable
        onlyOwner
        returns (bool)
    {
        return dex.swapWithExactSupply(path, supplyAmount, minTargetAmount);
    }

    function swapWithExactTarget(address[] memory path, uint256 targetAmount, uint256 maxSupplyAmount)
        public
        payable
        onlyOwner
        returns (bool)
    {
        return dex.swapWithExactTarget(path, targetAmount, maxSupplyAmount);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 maxAmountA,
        uint256 maxAmountB,
        uint256 minShareIncrement
    ) public payable onlyOwner returns (bool) {
        return dex.addLiquidity(tokenA, tokenB, maxAmountA, maxAmountB, minShareIncrement);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 removeShare,
        uint256 minWithdrawnA,
        uint256 minWithdrawnB
    ) public payable onlyOwner returns (bool) {
        return dex.removeLiquidity(tokenA, tokenB, removeShare, minWithdrawnA, minWithdrawnB);
    }

    // allow payments to this contract
    receive() external payable {}
}
