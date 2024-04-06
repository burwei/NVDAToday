// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NvdaToday} from "../src/NvdaToday.sol";

contract PublicNvdaToday is NvdaToday {
    function publicSettleBets(uint price) public {
        settleBets(price);
    }
}

contract NvdaTodayTest is Test {
    PublicNvdaToday nvdaToday;

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function setUp() public {
        nvdaToday = new PublicNvdaToday();
    }

    function testBetHigher() public {
        uint initCallerBalance = address(this).balance;
        uint initCalleeBalance = address(nvdaToday).balance;

        // First test case: bet 1 ether
        nvdaToday.betHigher{value: 1 ether}();
        assertEq(nvdaToday.totalStakeBetHigher(), 1 ether);
        assertEq(address(this).balance, initCallerBalance - 1 ether);
        assertEq(address(nvdaToday).balance, initCalleeBalance + 1 ether);

        // Second test case: bet another 2 ether
        nvdaToday.betHigher{value: 2 ether}();
        assertEq(nvdaToday.totalStakeBetHigher(), 3 ether);
        assertEq(address(this).balance, initCallerBalance - 3 ether);
        assertEq(address(nvdaToday).balance, initCalleeBalance + 3 ether);
    }

    function testBetLower() public {
        uint initCallerBalance = address(this).balance;
        uint initCalleeBalance = address(nvdaToday).balance;

        // First test case: bet 1 ether
        nvdaToday.betLower{value: 1 ether}();
        assertEq(nvdaToday.totalStakeBetLower(), 1 ether);
        assertEq(address(this).balance, initCallerBalance - 1 ether);
        assertEq(address(nvdaToday).balance, initCalleeBalance + 1 ether);

        // Second test case: bet another 2 ether
        nvdaToday.betLower{value: 2 ether}();
        assertEq(nvdaToday.totalStakeBetLower(), 3 ether);
        assertEq(address(this).balance, initCallerBalance - 3 ether);
        assertEq(address(nvdaToday).balance, initCalleeBalance + 3 ether);
    }

    function testSettleBets() public {
        uint initCallerBalance = address(this).balance;
        uint initCalleeBalance = address(nvdaToday).balance;

        // First test case: price is higher than last price, bet higher
        nvdaToday.betHigher{value: 1 ether}();
        nvdaToday.publicSettleBets(2);
        assertEq(nvdaToday.totalStakeBetHigher(), 0);
        assertEq(nvdaToday.totalStakeBetLower(), 0);
        assertEq(address(this).balance, initCallerBalance);
        assertEq(address(nvdaToday).balance, initCalleeBalance);

        // Second test case: price is higher than last price, bet lower
        nvdaToday.betLower{value: 1 ether}();
        nvdaToday.publicSettleBets(2);
        assertEq(nvdaToday.totalStakeBetHigher(), 0);
        assertEq(nvdaToday.totalStakeBetLower(), 1 ether);
        assertEq(address(this).balance, initCallerBalance - 1 ether);
        assertEq(address(nvdaToday).balance,initCalleeBalance + 1 ether);
    }

    function testProcessBets() public {
        // Set block.timestamp to a time within 20:00 - 23:00 UTC
        uint validTimestamp = 1712696400; // This is 2024-04-09 @ 21:00 (UTC)
        vm.warp(validTimestamp);

        // This function's success depends on other contract state (like settleBets and getNvdaPrice).
        // For this example, we'll just call the function assuming those conditions are handled.
        nvdaToday.processBets();
    }

    function testProcessBetsOutsideAllowedHours() public {
        // Set block.timestamp to a time outside 20:00 - 23:00 UTC
        uint invalidTimestamp = 1712667600; // This is 2024-04-09 @ 13:00 (UTC)
        vm.warp(invalidTimestamp); // 'vm.warp' manipulates the block timestamp

        // Attempt to call processBets and expect it to fail
        vm.expectRevert(bytes("You can only call this function between 21:00 and 22:00 UTC"));
        nvdaToday.processBets();
    }
}
