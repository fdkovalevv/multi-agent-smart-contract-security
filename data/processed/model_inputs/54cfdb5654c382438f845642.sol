contract ERC20 {
    function totalSupply() constant returns (uint totalSupply);
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool success);
    function transferFrom(address _from, address _to, uint _value) returns (bool success);
    function approve(address _spender, uint _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract FixedSupplyToken is ERC20 {
    string public name;
    string public symbol;
    uint256 _totalSupply;
    uint8 public decimals;

                                
    mapping(address => uint256) balances;

                                                                             
    mapping(address => mapping (address => uint256)) allowed;

                  
    function FixedSupplyToken(
      string _name,
      string _symbol,
      uint256 _supply,
      uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        _totalSupply = _supply;
        decimals = _decimals;
        balances[msg.sender] = _totalSupply;
    }

    function totalSupply() constant returns (uint256 totalSupply) {
        totalSupply = _totalSupply;
    }

                                                   
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

                                                                   
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

                                                                     
                                                                                          
                                                                                             
                                                                                   
                                                                                       
                                            
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

                                                                                             
                                                                                        
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract TokenToken is FixedSupplyToken{
  TokenTrader[] public tokenExchanges;
  uint256[] public tokenRatios;                                          
                                                                   
  uint256 tokensBought = 0;

  address public owner;
  event OwnershipTransferred(address indexed _from, address indexed _to);

                                                                                
                                                                            

                                                                                      

  function TokenToken(
    string _name,
    string _symbol,
    uint256 _supply,
    uint8 _decimals,
    TokenTrader[] initialTokenExchanges,
    uint256[] initialTokenRatios
    ) FixedSupplyToken(
      _name,
      _symbol,
      _supply,
      _decimals
    ) {
    tokenExchanges = initialTokenExchanges;
    tokenRatios = initialTokenRatios;
    owner = msg.sender;
  }

  modifier onlyOwner {
      if (msg.sender != owner) throw;
      _;
  }

  function transferOwnership(address newOwner) onlyOwner {
      OwnershipTransferred(owner, newOwner);
      owner = newOwner;
  }

  function setPurchaseRatios (
    TokenTrader[] newTokenExchanges,
    uint256[] newTokenRatios
  ) onlyOwner returns (bool success) {
                                        
                                                                 
                                             
      tokenExchanges = newTokenExchanges;
      tokenRatios = newTokenRatios;
      return true;
  }

  function buyPrice() returns (uint totalPrice) {
    totalPrice = 0;
    for (uint i = 0; i < tokenExchanges.length; ++i) {
      totalPrice += tokenExchanges[i].buyPrice() * tokenRatios[i] / 1e18;
    }
    return totalPrice;
  }

  function sellPrice() returns (uint totalPrice) {
    totalPrice = 0;
    for (uint i = 0; i < tokenExchanges.length; ++i) {
      totalPrice += tokenExchanges[i].sellPrice() * tokenRatios[i] / 1e18;
    }
    return totalPrice;
  }

  function () {                                                
    buy();
  }
  function buy() payable returns (uint amount){                     

    amount = msg.value / buyPrice();
    for (uint i = 0; i < tokenExchanges.length; ++i) {
      TokenTrader tokenExchange = tokenExchanges[i];
      tokenExchange.transfer(msg.value * tokenRatios[i] / 1e18);
    }
    tokensBought += amount;
    balances[msg.sender] += amount;                                                        
    balances[this] -= amount;                                                                  
    Transfer(this, msg.sender, amount);                                                         
    return amount;                                                                 
  }

  function sell(uint amount) returns (uint revenue){                    
    if (balances[msg.sender] < amount ) throw;                                                  
    balances[this] += amount;                                                              
    balances[msg.sender] -= amount;                                                                

    uint256 subTokensToSell = 0;
    revenue = 0;
    for (uint i = 0; i < tokenExchanges.length; ++i) {                                                 
      TokenTrader tokenExchange = tokenExchanges[i];
      subTokensToSell = ERC20(tokenExchange.asset()).balanceOf(this)*amount/tokensBought;

      revenue += subTokensToSell * tokenExchange.sellPrice();
      ERC20(tokenExchange.asset()).approve(address(tokenExchange), subTokensToSell);                
      tokenExchange.takerSellAsset(subTokensToSell);             
    }

    tokensBought -= amount;
    msg.sender.transfer(revenue);
    Transfer(msg.sender, this, amount);                                                         
    return revenue;                                                            
  }

  function breakdown(uint amount) {                         
    if (balances[msg.sender] < amount ) throw;                                                  
    balances[this] += amount;                                                              
    balances[msg.sender] -= amount;                                                                

    uint256 subTokensToSell = 0;
    for (uint i = 0; i < tokenExchanges.length; ++i) {                                                 
      TokenTrader tokenExchange = tokenExchanges[i];
      subTokensToSell = ERC20(tokenExchange.asset()).balanceOf(this)*amount/tokensBought;
      ERC20(tokenExchange.asset()).transfer(msg.sender, subTokensToSell);
    }

    tokensBought -= amount;
    Transfer(msg.sender, this, amount);                                                         
  }

  function rebalance(TokenTrader fromExchange, TokenTrader toExchange, uint256 fromPercent) onlyOwner {
    uint256 subTokensToSell = ERC20(fromExchange.asset()).balanceOf(this) * fromPercent / 1e18;

    uint256 revenue = subTokensToSell * fromExchange.sellPrice();
    ERC20(fromExchange.asset()).approve(address(fromExchange), subTokensToSell);                
    fromExchange.takerSellAsset(subTokensToSell);             

    toExchange.transfer(revenue);                                    
  }

  function kill() { if (msg.sender == owner) selfdestruct(owner); }
}