// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {NvdaToday} from "../src/NvdaToday.sol";

contract MockNvdaToday is NvdaToday {
    function getPlayersBetHigher() public view returns (address[] memory) {
        return playersBetHigher;
    }

    function getPlayersBetLower() public view returns (address[] memory) {
        return playersBetLower;
    }

    function getStakesBetHigherByAddress(
        address player
    ) public view returns (uint) {
        return stakesBetHigher[player];
    }

    function getStakesBetLowerByAddress(
        address player
    ) public view returns (uint) {
        return stakesBetLower[player];
    }

    function getLastNvdaPrice() internal pure override returns (uint) {
        return 0;
    }

    function publicSettleBets(uint price) public {
        settleBets(price);
    }
}

contract NvdaTodayTest is Test {
    MockNvdaToday nvdaToday;

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function setUp() public {
        nvdaToday = new MockNvdaToday();
    }

    function testBetHigher() public {
        uint initCallerBalance = address(this).balance;
        uint initCalleeBalance = address(nvdaToday).balance;

        uint rawStake = (1 ether + nvdaToday.PROCESS_FEE());
        uint stake = 1 ether;
        nvdaToday.betHigher{value: rawStake}();

        assertEq(nvdaToday.totalStakeBetHigher(), stake);
        assertEq(address(this).balance, initCallerBalance - rawStake);
        assertEq(address(nvdaToday).balance, initCalleeBalance + rawStake);
        assertEq(nvdaToday.totalStakeBetHigher(), stake);
        assertEq(nvdaToday.totalStakeBetLower(), 0);
        assertEq(nvdaToday.getPlayersBetHigher().length, 1);
        assertEq(nvdaToday.getPlayersBetHigher()[0], address(this));
        assertEq(nvdaToday.getStakesBetHigherByAddress(address(this)), stake);
    }

    function testBetHigherWithoutEnoughFunds() public {
        uint initCalleeBalance = address(nvdaToday).balance;

        vm.expectRevert(bytes("You must bet more than 1 finney"));
        nvdaToday.betHigher{value: 100 gwei}();

        assertEq(address(nvdaToday).balance, initCalleeBalance);
        assertEq(nvdaToday.totalStakeBetHigher(), 0);
        assertEq(nvdaToday.totalStakeBetLower(), 0);
        assertEq(nvdaToday.getPlayersBetHigher().length, 0);
        assertEq(nvdaToday.getStakesBetHigherByAddress(address(this)), 0);
    }

    function testBetLower() public {
        uint initCallerBalance = address(this).balance;
        uint initCalleeBalance = address(nvdaToday).balance;

        uint rawStake = (1 ether + nvdaToday.PROCESS_FEE());
        uint stake = 1 ether;
        nvdaToday.betLower{value: rawStake}();

        assertEq(nvdaToday.totalStakeBetLower(), 1 ether);
        assertEq(address(this).balance, initCallerBalance - rawStake);
        assertEq(address(nvdaToday).balance, initCalleeBalance + rawStake);
        assertEq(nvdaToday.totalStakeBetHigher(), 0);
        assertEq(nvdaToday.totalStakeBetLower(), stake);
        assertEq(nvdaToday.getPlayersBetLower().length, 1);
        assertEq(nvdaToday.getPlayersBetLower()[0], address(this));
        assertEq(nvdaToday.getStakesBetLowerByAddress(address(this)), stake);
    }

    function testBetLowerWithoutEnoughFunds() public {
        uint initCalleeBalance = address(nvdaToday).balance;

        vm.expectRevert(bytes("You must bet more than 1 finney"));
        nvdaToday.betLower{value: 100 gwei}();

        assertEq(address(nvdaToday).balance, initCalleeBalance);
        assertEq(nvdaToday.totalStakeBetHigher(), 0);
        assertEq(nvdaToday.totalStakeBetLower(), 0);
        assertEq(nvdaToday.getPlayersBetLower().length, 0);
        assertEq(nvdaToday.getStakesBetLowerByAddress(address(this)), 0);
    }

    function testSettleBets() public {
        uint initCallerBalance = address(this).balance;
        uint initCalleeBalance = address(nvdaToday).balance;

        // First test case: price is higher than last price, bet higher
        uint rawStake = (1 ether + nvdaToday.PROCESS_FEE());
        uint stake = 1 ether;
        nvdaToday.betHigher{value: rawStake}();
        nvdaToday.publicSettleBets(2);

        assertEq(nvdaToday.totalStakeBetHigher(), 0);
        assertEq(nvdaToday.totalStakeBetLower(), 0);
        assertEq(address(this).balance, initCallerBalance); // all process fees are sent to the caller who called settleBets
        assertEq(address(nvdaToday).balance, initCalleeBalance);
        assertEq(nvdaToday.getPlayersBetHigher().length, 0);
        assertEq(nvdaToday.getPlayersBetLower().length, 0);
        assertEq(nvdaToday.getStakesBetHigherByAddress(address(this)), 0);

        // Second test case: continue the scenario, now price is higher than last price, bet lower
        nvdaToday.betLower{value: rawStake}();
        nvdaToday.publicSettleBets(2);

        assertEq(nvdaToday.totalStakeBetHigher(), 0);
        assertEq(nvdaToday.totalStakeBetLower(), stake); 
        assertEq(address(this).balance, initCallerBalance - stake); // all process fees are sent to the caller who called settleBets
        assertEq(address(nvdaToday).balance, initCalleeBalance + stake);
        assertEq(nvdaToday.getPlayersBetHigher().length, 0);
        assertEq(nvdaToday.getPlayersBetLower().length, 0);
        assertEq(nvdaToday.getStakesBetHigherByAddress(address(this)), 0);
    }

    function testProcessBets() public {
        // Set block.timestamp to a time within 21:00 - 23:59 UTC
        uint validTimestamp = 1712696400; // This is 2024-04-09 @ 21:00 (UTC)
        vm.warp(validTimestamp);

        // This function's success depends on other contract state (like settleBets and getNvdaPrice).
        // For this example, we'll just call the function assuming those conditions are handled.
        nvdaToday.processBets();
    }

    function testProcessBetsOutsideAllowedHours() public {
        // Set block.timestamp to a time outside 21:00 - 23:59 UTC
        uint invalidTimestamp = 1712667600; // This is 2024-04-09 @ 13:00 (UTC)
        vm.warp(invalidTimestamp); // 'vm.warp' manipulates the block timestamp

        // Attempt to call processBets and expect it to fail
        vm.expectRevert(
            bytes("You can only call this function between 21:00 and 23:59 UTC")
        );
        nvdaToday.processBets();
    }
}
