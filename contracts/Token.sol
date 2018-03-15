pragma solidity ^0.4.15;

import './interfaces/ERC20Interface.sol';

/**
 * @title Token
 * @dev Contract that implements ERC20 token standard
 * Is deployed by `Crowdsale.sol`, keeps track of balances, etc.
 */

contract Token is ERC20Interface {
	
  mapping(address => uint256) public balances;
  mapping(address => mapping (address => uint256)) public allowed;
  
  event Transfer(address indexed _from, address indexed _to, uint256 _value)
  event Approval(address indexed _owner, address indexed _spender, uint256 _value)
  
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) returns (bool success) {
    //require(_value <= totalSupply);
    require(balances[msg.sender] >= _value);
    balances[msg.sender] -= _value
    balances[_to] += _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
    uint256 allowed_value = allowed[msg.sender][_from];
    require(balances[_from] >= _value && allowed_value >= _value);
    balances[_from] -= _value; 
    balances[_to] += _value; 
    allowed[msg.sender][_from] -= value;
    return true;
  }

  function approve(address _spender, uint256 _value) returns (bool success){
    allowed[msg.sender][_spender] = _value
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) view returns (uint256 remaining){
    return allowed[_owner][_spender];
  }

}
