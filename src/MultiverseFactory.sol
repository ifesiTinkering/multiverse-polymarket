// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./MultiverseVault.sol";

contract MultiverseFactory {
    event VaultCreated(
        IERC20   indexed parentToken,
        bytes32  indexed questionId,
        address  vault,
        address  yesToken,
        address  noToken
    );

    // Partition the parent token into YES and NO tokens.
    // The vault address is deterministic.
    // Only one vault is deployed per each set of wrapped asset and resolution oracle.
    function partition(
        IERC20 parentToken,
        IUmaCtfAdapter oracle,
        bytes32 qid
    ) external returns (address vault, address yesToken, address noToken) {
        // Compute the predicted address of the vault
        bytes memory params = abi.encode(parentToken, oracle, qid);
        bytes32 salt = keccak256(params);
        bytes32 byteHash = keccak256(
            abi.encodePacked(
                type(MultiverseVault).creationCode,
                params
            )
        );
        vault = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            salt,
                            byteHash
                        )
                    )
                )
            )
        );
        // Deploy the vault if it doesn't exist
        if (vault.code.length == 0) {
            bytes memory bytecode = abi.encodePacked(
                type(MultiverseVault).creationCode,
                params
            );
            assembly {
                vault := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
                if iszero(vault) { revert(0, 0) }
            }
            emit VaultCreated(parentToken, qid, vault, 
                MultiverseVault(vault).yesToken(), 
                MultiverseVault(vault).noToken()
            );
        }
        
        yesToken = MultiverseVault(vault).yesToken();
        noToken  = MultiverseVault(vault).noToken();
    }
}
