// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

contract LlamaVault is ERC4626 {
    using SafeTransferLib for ERC20;

    ERC20 public immutable token;
    address public immutable llamapay;

    constructor(ERC20 _token, address _llamapay)
        ERC4626(_token, _vaultName(_token), _vaultSymbol(_token))
    {
        token = _token;
        llamapay = _llamapay;
    }

    function deposit(uint256 assets, address receiver)
        public
        virtual
        override
        returns (uint256 shares)
    {
        require(msg.sender == llamapay, "not llamapay");
        // Check for rounding error since we round down in previewDeposit.
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");

        // Need to transfer before minting or ERC777s could reenter.
        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function mint(uint256 shares, address receiver)
        public
        virtual
        override
        returns (uint256 assets)
    {
        require(msg.sender == llamapay, "not llamapay");
        assets = previewMint(shares); // No need to check for rounding error, previewMint rounds up.

        // Need to transfer before minting or ERC777s could reenter.
        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual override returns (uint256 shares) {
        require(msg.sender == llamapay, "not llamapay");
        shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.

        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max)
                allowance[owner][msg.sender] = allowed - shares;
        }

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual override returns (uint256 assets) {
        require(msg.sender == llamapay, "not llamapay");
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max)
                allowance[owner][msg.sender] = allowed - shares;
        }

        // Check for rounding error since we round down in previewRedeem.
        require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
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
