contract token { 
                                       
    string public standard = 'Token 0.1';
    
	string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
	
    mapping (address => uint256) public coinBalanceOf;
    event CoinTransfer(address sender, address receiver, uint256 amount);

                                                                                      
  function token(
        uint256 initialSupply,	
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) {
        coinBalanceOf[msg.sender] = initialSupply;                                                    
        totalSupply = initialSupply;                                              
        name = tokenName;                                                                       
        symbol = tokenSymbol;                                                                     
        decimals = decimalUnits;                                                                      
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return coinBalanceOf[_owner];
    }

                                  
    function sendCoin(address receiver, uint256 amount) returns(bool sufficient) {
        if (coinBalanceOf[msg.sender] < amount) return false;
        coinBalanceOf[msg.sender] -= amount;
        coinBalanceOf[receiver] += amount;
        CoinTransfer(msg.sender, receiver, amount);
        return true;
    }
}