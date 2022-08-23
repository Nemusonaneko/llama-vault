//SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {LlamaVaultFactory} from "../src/LlamaVaultFactory.sol";

contract LlamaVaultFactory is Script {
    function run() public {
        vm.startBroadcast();
        LlamaVaultFactory llamaVault = new LlamaVaultFactory{
            salt: bytes32("llama")
        }();
    }
}
