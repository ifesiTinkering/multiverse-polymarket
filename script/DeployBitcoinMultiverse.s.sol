// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../src/PolyverseFinance.sol";

interface IERC20Meta is IERC20 {
    function decimals() external view returns (uint8);
}

contract DeployBitcoinMultiverse is Script {
    function run() external {
        uint256 pk = vm.envUint("POLYGON_PRIVATE_KEY");
        vm.startBroadcast(pk);

        /* -----------------------------------------------------------------
         *  Polymarket binary market: “Bitcoin above $105 000 on Feb 7?”
         *
         *  UMA CTF Adapter v3 (Polygon): 0x2F5e3684cb1F318ec51b00Edba38d79Ac2c0aA9d
         *  questionId                  : 0xcd4dac4522cab9b4feb28ac67acac37b0fc42a6ba71514f6ff1614842bf68c3f
         *  Resolution tx              : 0x88b33d940ea0dff372f5fc4d614d93d872ba05cfe6af9f38d2a7c118a3c95176
         *                              (14 Feb 2025 07:11 UTC) – settledPrice = 1 (“No” won)
         * ----------------------------------------------------------------- */

        IERC20Meta parentToken = IERC20Meta(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619); // Polygon WETH
        IUmaCtfAdapter oracle =
            IUmaCtfAdapter(0x2F5e3684cb1F318ec51b00Edba38d79Ac2c0aA9d);
        bytes32 qid = 0xcd4dac4522cab9b4feb28ac67acac37b0fc42a6ba71514f6ff1614842bf68c3f;

        MultiverseTokensFactory factory = new MultiverseTokensFactory();
        (address vaultAddr, address yesToken, address noToken) =
            factory.partition(parentToken, oracle, qid);

        MultiverseVault vault = MultiverseVault(vaultAddr);

        // 1 WETH = 1e18 (18 decimals)
        uint256 amount = 1 ether;
        parentToken.approve(vaultAddr, amount);

        // Push down 1 WETH → receive 1 YES + 1 NO
        vault.pushDown(amount);

        // Pull up 0.5 WETH using both YES and NO (burns 0.5 each)
        uint256 half = amount / 2;
        VerseToken(yesToken).approve(vaultAddr, half);
        VerseToken(noToken).approve(vaultAddr, half);
        vault.pullUp(half);

        // Settle remaining 0.5 WETH by burning 0.5 NO (settledPrice = 1)
        VerseToken(noToken).approve(vaultAddr, half);
        vault.settle(half);

        vm.stopBroadcast();
    }
}
