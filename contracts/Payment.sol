// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Payment is Ownable, ReentrancyGuard {

    address public paymentToken;
    address public bonusToken;
    mapping(address => uint256) balances;
    mapping(address => uint256) bonusBalances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event NewBalanceAdded(address indexed balanceAddress, uint256 indexed amount);
    event BonusBalanceAdded(address indexed bonusTokenAddress, uint256 indexed bonusTokenAmount);
    event BalanceClaimed(address indexed ownerAddress, uint256 indexed amount);
    event BonusBalanceClaimed(address indexed ownerAddress, uint256 indexed bonusTokenAmount);

    constructor (address _paymentToken) {
        paymentToken = _paymentToken;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function addNewBalance(address _address, uint _balance, address _bonusTokenAddress, uint _bonusTokenAmount) public onlyOwner {
        balances[_address] += _balance;
        IERC20(paymentToken).transferFrom(msg.sender, address(this), _balance);
        emit NewBalanceAdded(_address, _balance);
        if (_bonusTokenAmount > 0) {
            bonusBalances[_address] += _bonusTokenAmount;
            IERC20(_bonusTokenAddress).transferFrom(msg.sender, address(this), _bonusTokenAmount);
            emit BonusBalanceAdded(_bonusTokenAddress, _bonusTokenAmount);
        }
    }


    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
    
    function bonusBalanceOf(address account) external view returns (uint256) {
        return bonusBalances[account];
    }

    function claimTokens() external nonReentrant {
        uint _amount = balances[msg.sender];
        require(balances[msg.sender] > 0, "Cannot claim 0 tokens");
        IERC20(paymentToken).transfer(msg.sender, _amount);
        balances[msg.sender] -= _amount;
        emit BalanceClaimed(msg.sender, _amount);

        if (bonusBalances[msg.sender] > 0) {
        uint _bonusAmount = bonusBalances[msg.sender];
        IERC20(bonusToken).transfer( msg.sender, _bonusAmount);
        bonusBalances[msg.sender] -= _bonusAmount;
        emit BonusBalanceClaimed(msg.sender, _bonusAmount);
        }
    }
}
