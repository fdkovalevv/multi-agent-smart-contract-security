contract EosPizzaSliceConfig {
                             
    string constant NAME = "EOS.Pizza";

                               
    string constant SYMBOL = "EPS";

                                            
    uint8 constant DECIMALS = 18;                    

                                                  
    uint constant DECIMALS_FACTOR = 10 ** uint(DECIMALS);
}

contract ERC20TokenInterface {
    uint public totalSupply;                                                    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    function balanceOf(address _owner) public constant returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);

}

contract ERC20Token is ERC20TokenInterface {
    using SafeMath for uint;

                              
    mapping (address => uint) balances;

                                              
    mapping (address => mapping (address => uint)) allowed;



       
                                                    
      
                                                                   
      
                                                             
       
    function balanceOf(address _account) public constant returns (uint balance) {
        return balances[_account];
    }

       
                                                         
      
                                                                                         
                                                  
      
                                                          
       
    function transfer(address _to, uint _value) public returns (bool success) {
        if (balances[msg.sender] < _value || _value == 0) {

            return false;
        }

        balances[msg.sender] -= _value;
        balances[_to] = balances[_to].plus(_value);


        Transfer(msg.sender, _to, _value);

        return true;
    }

       
                                                                                           
      
                                              
                                               
                                                            
      
                                                          
       
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        if (balances[_from] < _value || allowed[_from][msg.sender] < _value || _value == 0) {
            return false;
        }

        balances[_to] = balances[_to].plus(_value);
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;


        Transfer(_from, _to, _value);

        return true;
    }

       
                                                                        
      
                                                                                                
                                                                      
      
                                                          
       
    function approve(address _spender, uint _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

       
                                                                                                             
      
                                                            
                                                               
      
                                                      
       
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
}

contract HasOwner {
                     
    address public owner;

                                   
    address public newOwner;

       
                            
      
                                              
       
    function HasOwner(address _owner) internal {
        owner = _owner;
    }

       
                                                                                            
       
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

       
                                                                 
      
                                                          
                                                     
       
    event OwnershipTransfer(address indexed _oldOwner, address indexed _newOwner);

       
                                                                          
                                                                                
                                                                              
                                           
      
                                                              
       
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

       
                                                                                   
                 
       
    function acceptOwnership() public {
        require(msg.sender == newOwner);

        OwnershipTransfer(owner, newOwner);

        owner = newOwner;
    }
}

contract Freezable is HasOwner {
  bool public frozen = false;

     
                                                                               
     
  modifier requireNotFrozen() {
    require(!frozen);
    _;
  }

     
                                                    
     
  function freeze() onlyOwner public {
    frozen = true;
  }

     
                                                      
     
  function unfreeze() onlyOwner public {
    frozen = false;
  }
}

contract FreezableERC20Token is ERC20Token, Freezable {
       
                                                                                              
      
                                                                                         
                                                  
      
                                                          
       
    function transfer(address _to, uint _value) public requireNotFrozen returns (bool success) {
        return super.transfer(_to, _value);
    }

       
                                                                                           
      
                                              
                                               
                                                            
      
                                                          
       
    function transferFrom(address _from, address _to, uint _value) public requireNotFrozen returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }

       
                                                                        
      
                                                                                                
                                                                      
      
                                                          
       
    function approve(address _spender, uint _value) public requireNotFrozen returns (bool success) {
        return super.approve(_spender, _value);
    }

}

contract EosPizzaSlice is EosPizzaSliceConfig, HasOwner, FreezableERC20Token {
                             
    string public name;

                                
    string public symbol;

                                 
    uint8 public decimals;

       
                                                                                
                                                                      
       
    function EosPizzaSlice(uint _totalSupply) public
        HasOwner(msg.sender)
    {
        name = NAME;
        symbol = SYMBOL;
        decimals = DECIMALS;
        totalSupply = _totalSupply;
        balances[owner] = _totalSupply;
    }
}

contract EosPizzaSliceDonationraiserConfig is EosPizzaSliceConfig {
                                 
    uint constant CONVERSION_RATE = 100000;

                                                      
    uint constant TOKENS_HARD_CAP = 95 * (10**7) * DECIMALS_FACTOR;

                                                                               
    uint constant START_DATE = 1520630542;

                                                                                                                      
    uint constant END_DATE =  1526603720;


                                                         
    uint constant TOKENS_LOCKED_CORE_TEAM = 35 * (10**6) * DECIMALS_FACTOR;

                                                    
    uint constant TOKENS_LOCKED_ADVISORS = 125 * (10**5) * DECIMALS_FACTOR;

                                                              
    uint constant TOKENS_LOCKED_CORE_TEAM_RELEASE_DATE = END_DATE + 1 days;

                                                         
    uint constant TOKENS_LOCKED_ADVISORS_RELEASE_DATE = END_DATE + 1 days;

                                                        
    uint constant TOKENS_BOUNTY_PROGRAM = 25 * (10**5) * DECIMALS_FACTOR;

                              
    uint constant MAX_GAS_PRICE = 90000000000 wei;                  

                                      
    uint constant MIN_CONTRIBUTION =  0.05 ether;

                                
    uint constant INDIVIDUAL_ETHER_LIMIT =  4999 ether;
}

contract Whitelist is HasOwner
{
                        
    mapping(address => bool) public whitelist;

       
                            
       
    function Whitelist(address _owner) public
        HasOwner(_owner)
    {

    }

       
                                                                                            
       
    modifier onlyWhitelisted {
        require(whitelist[msg.sender]);
        _;
    }

       
                                                                  
      
                                                              
                                             
       
    function setWhitelistEntries(address[] _entries, bool _status) internal {
        for (uint32 i = 0; i < _entries.length; ++i) {
            whitelist[_entries[i]] = _status;
        }
    }

       
                                                                               
      
                                                                  
       
    function whitelistAddresses(address[] _entries) public onlyOwner {
        setWhitelistEntries(_entries, true);
    }

       
                                                                               
      
                                                                
       
    function blacklistAddresses(address[] _entries) public onlyOwner {
        setWhitelistEntries(_entries, false);
    }
}

contract EosPizzaSliceDonationraiser is EosPizzaSlice, EosPizzaSliceDonationraiserConfig, Whitelist {
                                                             
    bool public finalized = false;

                                                                                              
    address public beneficiary;

                                                           
    uint public conversionRate;

                                 
    uint public startDate;

                               
    uint public endDate;

                                      
    uint public hardCap;

                                        
    EosPizzaSliceSafe public eosPizzaSliceSafe;

                                                             
    uint internal minimumContribution;

                                                      
    uint internal individualLimit;

                                                       
    uint private tokensSold;



       
                                                                             
      
                                                
                                                
                                                                 
                                                                                          
                                                                                  
       
    event FundsReceived(address indexed _address, uint _ethers, uint _tokens, uint _newTotalSupply, uint _conversionRate);

       
                                                                                  
      
                                                              
       
    event BeneficiaryChange(address _beneficiary);

       
                                                                         
      
                                                               
       
    event ConversionRateChange(uint _conversionRate);

       
                                                                              
      
                                                          
                                                                         
                                                                     
       
    event Finalized(address _beneficiary, uint _ethers, uint _totalSupply);

       
                            
      
                                                                                                   
       
    function EosPizzaSliceDonationraiser(address _beneficiary) public
        EosPizzaSlice(0)
        Whitelist(msg.sender)
    {
        require(_beneficiary != 0);

        beneficiary = _beneficiary;
        conversionRate = CONVERSION_RATE;
        startDate = START_DATE;
        endDate = END_DATE;
        hardCap = TOKENS_HARD_CAP;
        tokensSold = 0;
        minimumContribution = MIN_CONTRIBUTION;
        individualLimit = INDIVIDUAL_ETHER_LIMIT * CONVERSION_RATE;

        eosPizzaSliceSafe = new EosPizzaSliceSafe(this);

                                                                                                                                                           
                    
    }

       
                                                          
      
                                                              
       
    function setBeneficiary(address _beneficiary) public onlyOwner {
        require(_beneficiary != 0);

        beneficiary = _beneficiary;

        BeneficiaryChange(_beneficiary);
    }

       
                                                                                                         
      
                                                                           
       
    function setConversionRate(uint _conversionRate) public onlyOwner {
        require(now < startDate);
        require(_conversionRate > 0);

        conversionRate = _conversionRate;
        individualLimit = INDIVIDUAL_ETHER_LIMIT * _conversionRate;

        ConversionRateChange(_conversionRate);
    }



       
                                                                                                            
       
    function() public payable {
        buyTokens();
    }

       
                                                                                          
       
                                                           
    function buyTokens() public payable {
        require(!finalized);
        require(now >= startDate);
        require(now <= endDate);
        require(tx.gasprice <= MAX_GAS_PRICE);                    
        require(msg.value >= minimumContribution);                                  
        require(tokensSold <= hardCap);

                                                                 
        uint tokens = msg.value.mul(conversionRate);
        balances[msg.sender] = balances[msg.sender].plus(tokens);

                                                                             
        require(balances[msg.sender] <= individualLimit);



        tokensSold = tokensSold.plus(tokens);
        totalSupply = totalSupply.plus(tokens);

        Transfer(0x0, msg.sender, tokens);

        FundsReceived(
            msg.sender,
            msg.value,
            tokens,
            totalSupply,
            conversionRate
        );
    }



       
                                                                                           
       
    function finalize() public onlyOwner {
        require((totalSupply >= hardCap) || (now >= endDate));
        require(!finalized);

        address contractAddress = this;
        Finalized(beneficiary, contractAddress.balance, totalSupply);

                                                                     
        beneficiary.transfer(contractAddress.balance);

                                                                       
        uint totalTokensLocked = eosPizzaSliceSafe.totalTokensLocked();
        balances[address(eosPizzaSliceSafe)] = balances[address(eosPizzaSliceSafe)].plus(totalTokensLocked);
        totalSupply = totalSupply.plus(totalTokensLocked);

                                                     
        balances[owner] = balances[owner].plus(TOKENS_BOUNTY_PROGRAM);
        totalSupply = totalSupply.plus(TOKENS_BOUNTY_PROGRAM);

                                                                                 
        finalized = true;

                             
        unfreeze();
    }

       
                                                                             
       

    function collect() public onlyOwner {

        address contractAddress = this;
                                                                     
        beneficiary.transfer(contractAddress.balance);

    }
}