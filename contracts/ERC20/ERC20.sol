// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";


interface IERC20 {

    function totalSupply() external view returns(uint256);

    function balanceOf(address account) external view returns(uint256);

    function allowance(address owner, address spender) external view returns(uint256);

    function transfer(address recipient, uint256 amount ) external returns(bool);

    function transfer_disney(address _client , address recipient, uint256 numTokens ) external returns(bool);

    function approve(address spender, uint256 amount) external returns(bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}


contract ChrisCoin is IERC20 {

    string public constant name = "ERC20ChrisCoin";
    string public constant symbol = "CHC";
    uint8 public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    using SafeMath for uint256;

    mapping (address => uint) balances;
    mapping (address => mapping(address => uint)) allowed;
    uint256 totalSuply_;

    constructor (uint initialSupply) public {
        totalSuply_ = initialSupply;
        balances[msg.sender] = totalSuply_;
    }

    function totalSupply() public override view returns(uint256){
        return totalSuply_;        
    }

    function increaseTotalSupply(uint newTokensAmount) public {
        totalSuply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address tokenOwner) public override view returns(uint256){
        return balances[tokenOwner];
    }

    function allowance(address owner, address delegate) public override view returns(uint256){
        return allowed[owner][delegate];
    }

    function transfer(address recipient, uint256 numTokens ) public override returns(bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }

    function transfer_disney(address _client , address recipient, uint256 numTokens ) public override returns(bool) {
        require(numTokens <= balances[_client]);
        balances[_client] = balances[_client].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(_client, recipient, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns(bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns(bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);

        emit Transfer(owner, buyer, numTokens);

        return true;
    }

}