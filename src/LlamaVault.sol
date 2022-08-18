// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";

contract LlamaVault is ERC4626 {
    ERC20 public immutable token;
    address public immutable owner;

    constructor(ERC20 _token, address _owner)
        ERC4626(_token, _vaultName(_token), _vaultSymbol(_token))
    {
        token = _token;
        owner = _owner;
    }

    function totalAssets() public view virtual override returns (uint256) {
        return token.balanceOf(address(this));
    }

    function _vaultName(ERC20 _token)
        private
        view
        returns (string memory vaultName)
    {
        vaultName = string.concat("Llama Wrapped ", _token.symbol());
    }

    function _vaultSymbol(ERC20 _token)
        private
        view
        returns (string memory vaultSymbol)
    {
        vaultSymbol = string.concat("llama,", _token.symbol());
    }
}
