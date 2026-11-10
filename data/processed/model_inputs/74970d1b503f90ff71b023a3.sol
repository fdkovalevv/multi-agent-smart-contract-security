contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract SafeMath {

                                                    
                             
                    
             
                                                                      

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}

contract MUSCToken is StandardToken, SafeMath {

               
    string public constant name = "Manchester United SC";
    string public constant symbol = "MUSC";
    uint256 public constant decimals = 18;
    string public version = "1.0";

                
    address public ethFundDeposit;                                            
    address public muscFundDeposit;                                                

                           
    bool public isFinalized;                                                      
    uint256 public fundingStartBlock;
    uint256 public fundingEndBlock;
    uint256 public constant muscFund = 30 * (10**6) * 10**decimals;                                      
    uint256 public constant tokenExchangeRate = 2000;                                                      
    uint256 public constant tokenCreationCap =  100 * (10**6) * 10**decimals;                           
    uint256 public constant tokenCreationMin =  0 * (10**6) * 10**decimals;                         


             
    event LogRefund(address indexed _to, uint256 _value);
    event CreateMUSC(address indexed _to, uint256 _value);

                  
    function MUSCToken(
        
        )
    {
      isFinalized = false ;                                                         
      ethFundDeposit = 0xeEad6BE557441c568A3984eC15B0fDCC85C3e008 ;
      muscFundDeposit = 0xEaBd227E940a9e876C604eF4CEb46DDF577c5977 ;
      fundingStartBlock = 5073730 ;
      fundingEndBlock = 5240572 ;
      totalSupply = muscFund;
      balances[muscFundDeposit] = muscFund;                                                              
      CreateMUSC(muscFundDeposit, muscFund);          
    }

                                                       
    function createTokens() payable external {
                                
      require (!isFinalized); 
                                                     
      require(block.number > fundingStartBlock) ; 
                                                   
      require(block.number < fundingEndBlock) ; 
                                   
      require(msg.value != 0) ;


      uint256 tokens = safeMult(msg.value, tokenExchangeRate);                                    
      uint256 checkedSupply = safeAdd(totalSupply, tokens);

                                             
                                                                                      
      require(tokenCreationCap > checkedSupply) ; 

      totalSupply = checkedSupply;
      balances[msg.sender] += tokens;                                                  
      CreateMUSC(msg.sender, tokens);                        
    }

                                                           
    function finalize() external {
                                
      require(!isFinalized) ; 
      
                                                                                             
      require(msg.sender == ethFundDeposit) ; 
      
                                                                                                      
      require(totalSupply > tokenCreationMin) ; 
      
                                                                                      
                                                    
                            
      isFinalized = true;
      
                                                                                                    
      require(ethFundDeposit.send(this.balance)) ; 
    }

                                                                                                 
    function refund() external {
                                                                                       
      require(!isFinalized) ; 
                                                                                                 
      require(block.number > fundingEndBlock) ; 
                                                                                    
      require(totalSupply < tokenCreationMin) ; 
                                                                                               
      require(msg.sender != muscFundDeposit) ; 
      uint256 muscVal = balances[msg.sender];
                                 
      require (muscVal != 0) ; 

      balances[msg.sender] = 0;
      totalSupply = safeSubtract(totalSupply, muscVal);              
      uint256 ethVal = muscVal / tokenExchangeRate;                                                    
      LogRefund(msg.sender, ethVal);                         
                                                                                                                           
      require(msg.sender.send(ethVal)) ; 
    }

}