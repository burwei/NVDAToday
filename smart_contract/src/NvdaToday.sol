// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "BokkyPooBahsDateTimeLibrary/contracts/BokkyPooBahsDateTimeLibrary.sol";
import "chainlink/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract NvdaToday {
    struct LastPrice {
        uint price;
        uint timestamp;
    }

    uint public constant MIN_BET = 1000000000000000; // 1 finney
    uint public constant PROCESS_FEE = 10000000000000; // 0.01 finney (1% fee or less)
    uint public constant PRECISION_FACTOR = 1000;

    LastPrice public lastPrice;
    uint public totalStakeBetHigher;
    uint public totalStakeBetLower;
    address[] internal playersBetHigher;
    address[] internal playersBetLower;
    mapping(address => uint) internal stakesBetHigher;
    mapping(address => uint) internal stakesBetLower;
    AggregatorV3Interface internal priceFeed;

    // Make the contract payable
    receive() external payable {}
    fallback() external payable {}

    // constructor initializes the price feed contract.
    // NOTICE: Remove the constructor when deploying to local testnet.
    // constructor() {
    //     // For NVDA/USD on BNB Mainnet (L1 mainnet).
    //     priceFeed = AggregatorV3Interface(
    //         0xea5c2Cbb5cD57daC24E26180b19a929F3E9699B8
    //     );

    //     // For NVDA/USD on Arbitrum Mainnet (L2 mainnet).
    //     priceFeed = AggregatorV3Interface(
    //         0x4881A4418b5F2460B21d6F08CD5aA0678a7f262F
    //     );

    //     // For SPY/USD on Arbitrum Sepolia (L2 testnet).
    //     // There's no NVDA/USD on any testnet, so we use SPY/USD instead.
    //     priceFeed = AggregatorV3Interface(
    //         0x4fB44FC4FA132d1a846Bd4143CcdC5a9f1870b06
    //     );

    //     uint price = getLastNvdaPrice();
    //     lastPrice = LastPrice(price, block.timestamp);
    // }

    function betHigher() public payable {
        require(msg.value >= MIN_BET, "You must bet more than 1 finney");
        uint stack = stakesBetHigher[msg.sender];
        if (stack == 0) {
            playersBetHigher.push(msg.sender);
        }
        stack += msg.value - PROCESS_FEE;
        totalStakeBetHigher += msg.value - PROCESS_FEE;
        stakesBetHigher[msg.sender] = stack;
    }

    function betLower() public payable {
        require(msg.value >= MIN_BET, "You must bet more than 1 finney");
        uint stack = stakesBetLower[msg.sender];
        if (stack == 0) {
            playersBetLower.push(msg.sender);
        }
        stack += msg.value - PROCESS_FEE;
        totalStakeBetLower += msg.value - PROCESS_FEE;
        stakesBetLower[msg.sender] = stack;
    }

    // settleBets calculates the winning amount for each player, transfers the winnings to their
    // addresses, and resets the stakes but keeps the total stake number if there are no winners.
    function settleBets(uint price) internal {
        uint totalWinning = totalStakeBetHigher + totalStakeBetLower;
        if (address(this).balance < totalWinning) {
            lastPrice.price = price;
            lastPrice.timestamp = block.timestamp;
            revert("Contract does not have enough balance to cover winnings");
        }

        if (price > lastPrice.price && playersBetHigher.length > 0) {
            for (uint i = 0; i < playersBetHigher.length; i++) {
                payable(playersBetHigher[i]).transfer(
                    (((totalWinning * PRECISION_FACTOR) / totalStakeBetHigher) *
                        stakesBetHigher[playersBetHigher[i]]) / PRECISION_FACTOR
                );
            }
            totalStakeBetHigher = 0;
            totalStakeBetLower = 0;
        } else if (price < lastPrice.price && playersBetLower.length > 0) {
            for (uint i = 0; i < playersBetLower.length; i++) {
                payable(playersBetLower[i]).transfer(
                    (((totalWinning * PRECISION_FACTOR) / totalStakeBetLower) *
                        stakesBetLower[playersBetLower[i]]) / PRECISION_FACTOR
                );
            }
            totalStakeBetHigher = 0;
            totalStakeBetLower = 0;
        } else {
            // No winner, stakes stay in the pool.
        }

        uint processedPlayers = 0;
        for (uint i = 0; i < playersBetHigher.length; i++) {
            delete stakesBetHigher[playersBetHigher[i]];
            processedPlayers++;
        }
        for (uint i = 0; i < playersBetLower.length; i++) {
            delete stakesBetLower[playersBetLower[i]];
            processedPlayers++;
        }
        delete playersBetHigher;
        delete playersBetLower;

        lastPrice.price = price;
        lastPrice.timestamp = block.timestamp;

        payable(msg.sender).transfer(processedPlayers * PROCESS_FEE); 
    }

    // getNvdaPrice returns the last closing price of NVDA stock.
    function getLastNvdaPrice() internal view virtual returns (uint) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();

        return uint(answer);
    }

    // processBets settles the bets based on the last closing price of NVDA stock.
    function processBets() public {
        // Check if it's in the allowed time range to call this function.
        uint currentHour = BokkyPooBahsDateTimeLibrary.getHour(block.timestamp);
        require(
            currentHour >= 21 && currentHour <= 23,
            "You can only call this function between 21:00 and 23:59 UTC"
        );

        // Check if the price has been updated today already.
        uint lastPriceUpdateDay = BokkyPooBahsDateTimeLibrary.getDay(
            lastPrice.timestamp
        );
        uint currentDay = BokkyPooBahsDateTimeLibrary.getDay(block.timestamp);
        if (lastPriceUpdateDay == currentDay) {
            revert("Price has been updated today already");
        }

        // Get the last price of NVDA stock and return if it's the same.
        uint price = getLastNvdaPrice();
        if (price == lastPrice.price) {
            return;
        }

        // Settle the bets based on the new price.
        settleBets(price);
    }

    // manualSettleBets settle the bets manually for testing purposes.
    // NOTICE: Remove this function when deploying to public mainnet or testnet.
    function manualSettleBets(uint price) public {
        settleBets(price);
    }

    // getBalance returns the balance of the contract for testing purposes.
    // NOTICE: Remove this function when deploying to public mainnet or testnet.
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
