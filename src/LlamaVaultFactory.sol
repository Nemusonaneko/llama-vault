// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.16;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {LlamaVault} from "./LlamaVault.sol";

error InvalidToken();

contract LlamaVaultFactory {
    bytes32 constant INIT_CODEHASH = keccak256(type(LlamaVault).creationCode);

    event LlamaVaultCreated(address token, address vault);

    function createLlamaVault(address _token) external returns (address vault) {
        if (_token == address(0)) revert InvalidToken();
        vault = address(
            new LlamaVault{salt: bytes32(uint256(uint160(_token)))}(
                ERC20(_token)
            )
        );
        emit LlamaVaultCreated(_token, vault);
    }

    function calculateLlamaVaultAddress(address _token)
        external
        view
        returns (address vault, bool deployed)
    {
        vault = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            bytes32(uint256(uint160(_token))),
                            INIT_CODEHASH
                        )
                    )
                )
            )
        );

        deployed = vault.code.length != 0;
    }
}
