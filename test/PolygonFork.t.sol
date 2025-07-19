// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/MultiverseFactory.sol";

interface IERC20Meta is IERC20 {
    function decimals() external view returns (uint8);
}

contract PolygonForkTest is Test {
    /* live addresses */
    address constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address constant ORACLE = 0x2F5e3684cb1F318ec51b00Edba38d79Ac2c0aA9d;
    bytes32 constant QID = 0xcd4dac4522cab9b4feb28ac67acac37b0fc42a6ba71514f6ff1614842bf68c3f;
    address constant FACTORY = 0xaD2C42aDf1Ee2acba8275A05030B420DCE1C34b1;

    IERC20Meta weth;
    MultiverseVault vault;
    VerseToken yes;
    VerseToken no;

    function setUp() public {
        vm.createSelectFork("polygon");

        weth = IERC20Meta(WETH);

        MultiverseFactory factory = new MultiverseFactory();
        (address vAddr, address y, address n) = factory.partition(weth, IUmaCtfAdapter(ORACLE), QID);

        vault = MultiverseVault(vAddr);
        yes = VerseToken(y);
        no = VerseToken(n);

        // fund account inside fork
        deal(WETH, address(this), 1 ether);
        weth.approve(vAddr, type(uint256).max);
        yes.approve(vAddr, type(uint256).max);
        no.approve(vAddr, type(uint256).max);
    }

    function testOnPolygon() public {
        vault.pushDown(1 ether);
        vault.pullUp(0.6 ether); // burn 0.6 YES + NO

        // real adapter is already resolved → settle works
        vault.settle(0.4 ether); // burn winning NO

        assertEq(weth.balanceOf(address(this)), 1 ether);
        assertEq(no.balanceOf(address(this)), 0);
        assertEq(yes.balanceOf(address(this)), 0.4 ether);
    }
}
