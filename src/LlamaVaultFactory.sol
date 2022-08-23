// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {LlamaVault} from "./LlamaVault.sol";

contract LlamaVaultFactory {
    bytes32 constant INIT_CODEHASH = keccak256(type(LlamaVault).creationCode);

    event LlamaVaultCreated(address token, address owner, address vault);

    function createVault(ERC20 _token) external returns (ERC4626 vault) {
        require(address(_token) != address(0), "invalid token");
        vault = new LlamaVault{
            salt: keccak256(abi.encodePacked(_token, msg.sender))
        }(_token, msg.sender);
        emit LlamaVaultCreated(address(_token), msg.sender, address(vault));
    }

    function calcVaultAddress(ERC20 _token, address _owner)
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
                            keccak256(abi.encodePacked(_token, _owner)),
                            INIT_CODEHASH
                        )
                    )
                )
            )
        );
        deployed = vault.code.length != 0;
    }
}
