// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {LlamaVault} from "./LlamaVault.sol";

contract LlamaVaultFactory {

    event LlamaVaultCreated(address token, address owner, address vault);

    function createVault(ERC20 _token, address _owner) external returns (ERC4626 vault) {
        require(address(_token) != address(0), "invalid token");
        require(_owner != address(0), "invalid owner");
        vault = new LlamaVault(_token, _owner);
        emit LlamaVaultCreated(address(_token), _owner, address(vault));
    }
}
