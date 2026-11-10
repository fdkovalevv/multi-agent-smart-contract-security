contract ERC20 {
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

}

contract StandardToken is ERC20, SafeMath {

                                                                        
  event Minted(address receiver, uint amount);

                                        
  mapping(address => uint) balances;

                            
  mapping (address => mapping (address => uint)) allowed;

                             
  function isToken() public constant returns (bool Yes) {
    return true;
  }

  function transfer(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    uint _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _address) constant returns (uint balance) {
    return balances[_address];
  }

  function approve(address _spender, uint _value) returns (bool success) {

                                                                           
                                                                        
                                                                
                                                                         
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

                                
modifier onlyPayloadSize(uint numWords) {
    assert(msg.data.length == numWords * 32 + 4);
    _;
}

}

contract CBToken is StandardToken {

    string public name = "CryptoBazar Token";
    string public symbol = "CBT";
    uint8 public decimals = 4;
    uint public totalSupply = 1000000000 * (10 ** uint(decimals));              
    uint public sellPrice = 1000000000000000 wei;                                
    
                         
    address public delegateContract;
    bool public contractUpgradable = false;
    address[] public previousDelegates;
    
                                                   
    mapping (address => bool) public allowedTransfer;
	
                                    
    mapping (address => uint) public specialBonus;
    
	                                     
	bool public TransferAllowed = true;                             
    bool public SalePaused = false;                                                    
    uint public currentBonus = 0;                                   
	
                                                   
	uint public StatsEthereumRaised = 0 wei;                       
	uint public StatsSold = 0;                    
	uint public StatsMinted = 0;                      
	uint public StatsTotal = 0;                       

                
    event Buy(address indexed sender, uint eth, uint tokens, uint bonus);                  
    event Mint(address indexed from, uint tokens);                                                
    event Burn(address indexed from, uint tokens);                                               
    event PriceChanged(string _text, uint _tokenPrice);                    
    event BonusChanged(string _text, uint _percent);                                      
    event DelegateChanged(address oldAddress, address newAddress);                                       
    
    address public owner = 0x0;               
    address public minter = 0x0;               
    address public wallet = 0x0;                       
 
function CBToken(address _owner, address _minter, address _wallet) payable {
    
      owner = _owner;
      minter = _minter;
      wallet = _wallet;
    
      balances[owner] = 0;
      balances[minter] = 0;
      balances[wallet] = 0;
        
      allowedTransfer[owner] = true;
      allowedTransfer[minter] = true;
      allowedTransfer[wallet] = true;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyMinter() {
        require(msg.sender == minter);
        _;
    }

                                                      
    function() payable {
        buy();
    }
    
                                                                                                               
    function price() constant returns (uint) {
        return sellPrice;
    }

                                              
    function changeContractUpgradability(bool _contractUpgradable) external onlyOwner {
        contractUpgradable = _contractUpgradable;
    }

                                                     
    function changeDelegate(address _newDelegate) external returns (bool) {
        require(msg.sender == owner || msg.sender == minter);

        if (_newDelegate != delegateContract) {
            previousDelegates.push(delegateContract);
            var oldDelegate = delegateContract;
            delegateContract = _newDelegate;
            DelegateChanged(oldDelegate, _newDelegate);
            return true;
        }

        return false;
    }

                                                             
    function functionOne(uint256 _valueOne, uint256 _valueTwo, uint256 _valueThree, uint256 _valueFour) onlyPayloadSize(4) returns (bool ok) {
        require(contractUpgradable);                                 
        return delegateContract.delegatecall(bytes4(sha3("functionOne(uint256,uint256,uint256,uint256)")), _valueOne, _valueTwo, _valueThree, _valueFour);
    }

    function functionTwo(uint256 _valueOne, uint256 _valueTwo, uint256 _valueThree, uint256 _valueFour) onlyPayloadSize(4) returns (bool ok) {
        require(contractUpgradable);                                 
        return delegateContract.delegatecall(bytes4(sha3("functionTwo(uint256,uint256,uint256,uint256)")), _valueOne, _valueTwo, _valueThree, _valueFour);
    }

    function functionThree(uint256 _valueOne, uint256 _valueTwo, uint256 _valueThree, uint256 _valueFour) onlyPayloadSize(4) returns (bool ok) {
        require(contractUpgradable);                                 
        return delegateContract.delegatecall(bytes4(sha3("functionThree(uint256,uint256,uint256,uint256)")), _valueOne, _valueTwo, _valueThree, _valueFour);
    }

    function functionFour(uint256 _valueOne, uint256 _valueTwo, uint256 _valueThree, uint256 _valueFour) onlyPayloadSize(4) returns (bool ok) {
        require(contractUpgradable);                                 
        return delegateContract.delegatecall(bytes4(sha3("functionFour(uint256,uint256,uint256,uint256)")), _valueOne, _valueTwo, _valueThree, _valueFour);
    }

    function functionFive(uint256 _valueOne, uint256 _valueTwo, uint256 _valueThree, uint256 _valueFour) onlyPayloadSize(4) returns (bool ok) {
        require(!SalePaused);                                           
        return delegateContract.delegatecall(bytes4(sha3("functionFive(uint256,uint256,uint256,uint256)")), _valueOne, _valueTwo, _valueThree, _valueFour);
    }

    function functionSix(uint256 _valueOne, uint256 _valueTwo, uint256 _valueThree, uint256 _valueFour) onlyPayloadSize(4) returns (bool ok) {
        require(!SalePaused);                                           
        return delegateContract.delegatecall(bytes4(sha3("functionSix(uint256,uint256,uint256,uint256)")), _valueOne, _valueTwo, _valueThree, _valueFour);
    }

                                                                           
    function setTokenPrice(uint _tokenPrice) external {
        require(msg.sender == owner || msg.sender == minter);
        sellPrice = _tokenPrice;
        PriceChanged("New price is ", _tokenPrice);
    }
    
                                             
    function setBonus(uint _percent) external {
        require(msg.sender == owner || msg.sender == minter);
        require(_percent >=0);
        currentBonus = safeAdd(100,_percent);
        BonusChanged("New bonus is ", _percent);
    }
    
                                                
    function setSpecialBonus(address _target, uint _percent) external {
        require(msg.sender == owner || msg.sender == minter);
        require(_percent >=0);
        specialBonus[_target] = safeAdd(100,_percent);
    }
     
                                       
    function setTransferAllowance(bool _allowance) external onlyOwner {
        TransferAllowed = _allowance;
    }
    
                                    
    function eventPause(bool _pause) external onlyOwner {
        SalePaused = _pause;
    }
    
                                            
    function mintTokens(address _target, uint _amount) external returns (bool) {
        require(msg.sender == owner || msg.sender == minter);
        require(_amount > 0);                                         
        uint amount=_amount * (10 ** uint256(decimals));
        require(safeAdd(StatsTotal, amount) <= totalSupply);                                                          
        balances[_target] = safeAdd(balances[_target], amount);
        StatsMinted = safeAdd(StatsMinted, amount);                                
        StatsTotal = safeAdd(StatsTotal, amount);                               
        Transfer(0, this, amount);
        Transfer(this, _target, amount);
        Mint(_target, amount);
        return true;
    }
    
                            
    function decreaseTokens(address _target, uint _amount) external returns (bool) {
        require(msg.sender == owner || msg.sender == minter);
        require(_amount > 0);                                         
        uint amount=_amount * (10 ** uint256(decimals));
        balances[_target] = safeSub(balances[_target], amount);
        StatsMinted = safeSub(StatsMinted, amount);                                
        StatsTotal = safeSub(StatsTotal, amount);                               
        Transfer(_target, 0, amount);
        Burn(_target, amount);
        return true;
    }
    
                                          
    function allowTransfer(address _target, bool _allow) external onlyOwner {
        allowedTransfer[_target] = _allow;
    }

                                           
    function buy() public payable returns(bool) {

        require(msg.sender != owner);                               
        require(msg.sender != minter);                              
        require(msg.sender != wallet);                                      
        require(!SalePaused);                                      
        require(msg.value >= price());                                                                     

        uint tokens = msg.value/price();                                              
        require(tokens > 0);                                         
        
                          
        if(currentBonus > 0){
        uint bonus = safeMul(tokens, currentBonus);
        bonus = safeDiv(bonus, 100);
        tokens = safeAdd(bonus, tokens);
        }
        
                                                           
        if(specialBonus[msg.sender] > 0){
        uint addressBonus = safeMul(tokens, specialBonus[msg.sender]);
        addressBonus = safeDiv(addressBonus, 100);
        tokens = safeAdd(addressBonus, tokens);
        }
        
        uint tokensToAdd=tokens * (10 ** uint256(decimals));
        
        require(safeAdd(StatsSold, tokensToAdd) <= totalSupply);                                                               
        
        wallet.transfer(msg.value);                                            
        
                                          
        balances[msg.sender] = safeAdd(balances[msg.sender], tokensToAdd);
        StatsSold = safeAdd(StatsSold, tokensToAdd);                              
        StatsTotal = safeAdd(StatsTotal, tokensToAdd);                               
        Transfer(0, this, tokensToAdd);
        Transfer(this, msg.sender, tokensToAdd);
        
        StatsEthereumRaised = safeAdd(StatsEthereumRaised, msg.value);                            
        
                                             
        Buy(msg.sender, msg.value, tokensToAdd, currentBonus);

        return true;
    }
    
    function transfer(address _to, uint _value) returns (bool success) {
        
                                
        if(!TransferAllowed){
            require(allowedTransfer[msg.sender]);
        }
        
    return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) returns (bool success) {
        
                                
        if(!TransferAllowed){
            require(allowedTransfer[msg.sender]);
        }
        
        return super.transferFrom(_from, _to, _value);
    }

                  
    function changeOwner(address _to) external onlyOwner() {
        balances[_to] = balances[owner];
        balances[owner] = 0;
        owner = _to;
    }

                   
    function changeMinter(address _to) external onlyOwner() {
        balances[_to] = balances[minter];
        balances[minter] = 0;
        minter = _to;
    }

                   
    function changeWallet(address _to) external onlyOwner() {
        balances[_to] = balances[wallet];
        balances[wallet] = 0;
        wallet = _to;
    }
}