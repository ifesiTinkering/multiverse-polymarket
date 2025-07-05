// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../src/MultiverseFactory.sol";

interface IERC20Meta is IERC20 {
    function decimals() external view returns (uint8);
}

contract DeployBitcoinMultiverse is Script {
    function run() external {
        uint256 pk = vm.envUint("POLYGON_PRIVATE_KEY");
        vm.startBroadcast(pk);

        /* -----------------------------------------------------------------
         *  Polymarket binary market: "Bitcoin above $105 000 on Feb 7?"
         *
         *  UMA CTF Adapter v3 (Polygon): 0x2F5e3684cb1F318ec51b00Edba38d79Ac2c0aA9d
         *  questionId: 0xcd4dac4522cab9b4feb28ac67acac37b0fc42a6ba71514f6ff1614842bf68c3f
         *  Resolution tx: 0x88b33d940ea0dff372f5fc4d614d93d872ba05cfe6af9f38d2a7c118a3c95176
         *                  (14 Feb 2025 07:11 UTC) – settledPrice = 1 ("No" won)
         * ----------------------------------------------------------------- */

        IERC20Meta parentToken = IERC20Meta(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619); // Polygon WETH
        IUmaCtfAdapter oracle =
            IUmaCtfAdapter(0x2F5e3684cb1F318ec51b00Edba38d79Ac2c0aA9d);
        bytes32 qid = 0xcd4dac4522cab9b4feb28ac67acac37b0fc42a6ba71514f6ff1614842bf68c3f;

        MultiverseFactory factory = new MultiverseFactory();
        (address vaultAddr, address yesToken, address noToken) =
            factory.partition(parentToken, oracle, qid);

        MultiverseVault vault = MultiverseVault(vaultAddr);

        // 0.001 WETH = 1e15 (18 decimals)
        uint256 amount = 0.001 ether;
        parentToken.approve(vaultAddr, amount);

        // Push down 0.001 WETH → receive 0.001 YES + 0.001 NO
        vault.pushDown(amount);

        // Pull up 0.0005 WETH using both YES and NO (burns 0.0005 each)
        uint256 half = amount / 2;
        VerseToken(yesToken).approve(vaultAddr, half);
        VerseToken(noToken).approve(vaultAddr, half);
        vault.pullUp(half);

        // Settle remaining 0.0005 WETH by burning 0.0005 NO (settledPrice = 1)
        VerseToken(noToken).approve(vaultAddr, half);
        vault.settle(half);

        vm.stopBroadcast();
    }
}
