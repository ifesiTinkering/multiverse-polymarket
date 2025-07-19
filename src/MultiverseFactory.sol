// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./MultiverseVault.sol";

contract MultiverseFactory {
    event VaultCreated( // the ERC-20 you’re wrapping WETH, USDC, etc.
        // the Polymarket/UMA question that will resolve the market
        // the address of the vault that will hold the YES and NO tokens
        // the address of the YES token
        // the address of the NO token
    IERC20 indexed parentToken, bytes32 indexed questionId, address vault, address yesToken, address noToken);

    // Partition the parent token into YES and NO tokens.

    //The triple (parentToken, oracle, qid) uniquely identifies a binary market,so the vault address can be deterministic.
    function partition(
        IERC20 parentToken, // the ERC-20 you’re splitting WETH, USDC, etc.
        IUmaCtfAdapter oracle, // the UMA/Polymarket oracle that will resolve the market
        bytes32 qid // the Polymarket/UMA question that will resolve the market
       
    ) external returns (address vault, address yesToken, address noToken) {
        // Compute the predicted address of the vault
        bytes memory params = abi.encode(parentToken, oracle, qid);
        bytes32 salt = keccak256(params);
        bytes32 byteHash = keccak256(abi.encodePacked(type(MultiverseVault).creationCode, params));
        vault = address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, byteHash)))));
        // Deploy the vault if it doesn't exist
        if (vault.code.length == 0) {
            bytes memory bytecode = abi.encodePacked(type(MultiverseVault).creationCode, params);
            assembly {
                vault := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
                if iszero(vault) { revert(0, 0) }
            }
            emit VaultCreated(
                parentToken, qid, vault, MultiverseVault(vault).yesToken(), MultiverseVault(vault).noToken()
            );
        }

        yesToken = MultiverseVault(vault).yesToken();
        noToken = MultiverseVault(vault).noToken();
    }
}
