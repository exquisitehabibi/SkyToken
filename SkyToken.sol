// the contract owner should be able to mint tokens to a provided address and any user should be able to burn and transfer tokens.
// approve, inc / dec Allowance accept decimal values i.e. enter 1 sky token = 1 * 10**18

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.4.0/contracts/security/Pausable.sol";

contract SkyToken is ERC20, Ownable, Pausable {
    mapping(address => bool) private _blacklist;

    constructor() ERC20("SkyToken", "SKT") {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals()))); // Send initial supply to owner
    }

    function mint(address to, uint256 amount) public whenNotPaused onlyOwner {
        require(!_blacklist[to], "ERC20: recipient is blacklisted");
        _mint(to, amount * (10 ** uint256(decimals())));
    }

    function burn(uint256 amount) public whenNotPaused {
        require(!_blacklist[msg.sender], "ERC20: recipient is blacklisted");
        _burn(msg.sender, amount * (10 ** uint256(decimals())));
    }

    function transfer(address to, uint256 amt) public override whenNotPaused returns (bool) {
        uint256 amount = amt* (10 ** uint256(decimals()));
        require(!_blacklist[msg.sender], "ERC20: sender is blacklisted");
        require(!_blacklist[to], "ERC20: recipient is blacklisted");
        require(to != address(0), "ERC20: transfer to the zero address");
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amt) public override whenNotPaused returns (bool) {
        uint256 amount = amt* (10 ** uint256(decimals()));
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_blacklist[to], "ERC20: recipient is blacklisted");
        if (msg.sender == owner()) {
            // If the caller is the owner, bypass the allowance check
            _transfer(from, to, amount);
            return true;
        } else {
            require(!_blacklist[from], "ERC20: sender is blacklisted");
            return super.transferFrom(from, to, amount);
        }
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function blacklistAddress(address account) public whenNotPaused onlyOwner {
        _blacklist[account] = true;
    }

    function unblacklistAddress(address account) public whenNotPaused onlyOwner {
        _blacklist[account] = false;
    }

    function isBlacklisted(address account) public view whenNotPaused returns (bool) {
        return _blacklist[account];
    }
}
