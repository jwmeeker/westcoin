// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title WestCoin
 * @dev Basic ERC20 token.
 */
contract WestCoin {
    
    string public constant name = "WestCoin";
    string public constant symbol = "WEST";
    uint8 public constant decimals = 18;  
    
    using SafeMath for uint256;
    
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);


    mapping(address => uint256) balances;
    // Map of all delegates approved to withdraw from a given account and the withdrawal sum allowed.
    mapping(address => mapping (address => uint256)) allowed;
    
    uint256 totalSupply_;
    
    constructor(uint256 total) {
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
    }
    
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }
    
    /**
     * @dev Moves `numTokens` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address receiver, uint numTokens) public returns (bool) {
        // Assert that the balance is sufficient for this transfer. Iff rollback safe.
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    
    /**
     * @dev Approves an allowance of `delegate` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     * 
     * Emits an {Approve} event.
     */
    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    /**
     * @dev Returns the current number of tokens that is approved to go from the
     * `owner` to the delegate. Default is none.
     */
    function allowance(address owner, address delegate) public view returns (uint) {
       return allowed[owner][delegate];
    }
    
    /**
     * @dev Allows a delegate approved for withdrawal to transfer owner funds to a third party account.
     */
    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        // Make sure the owner has enough to transfer and that the sender/delegate
        // has approval withdraw this amount.
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        Transfer(owner, buyer, numTokens);
        return true;
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a-b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256)   {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
