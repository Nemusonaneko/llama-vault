// SDPX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./mock/LlamaToken.sol";
import "../src/LlamaVaultFactory.sol";

contract LlamaVaultFactoryTest is Test {
    LlamaToken public llamaToken;
    LlamaVaultFactory public llamaVaultFactory;

    address public immutable alice = address(1);

    function setUp() public {
        llamaToken = new LlamaToken();
    }

    function testCreateVault() public {
        vm.prank(alice);
        llamaVaultFactory.createVault(llamaToken);
    }

}