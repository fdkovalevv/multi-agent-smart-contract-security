contract ERC23BasicToken {
    using SafeMath for uint256;
    uint256 public totalSupply;
    mapping(address => uint256) balances;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

    function tokenFallback(address _from, uint256 _value, bytes  _data) external {
        throw;
    }

    function transfer(address _to, uint256 _value, bytes _data) returns (bool success) {

                                          

        if(isContract(_to)) {
            transferToContract(_to, _value, _data);
        }
        else {
            transferToAddress(_to, _value, _data);
        }
        return true;
    }

    function transfer(address _to, uint256 _value) {

                                                                            
                                                      

        bytes memory empty;
        if(isContract(_to)) {
            transferToContract(_to, _value, empty);
        }
        else {
            transferToAddress(_to, _value, empty);
        }
    }

    function transferToAddress(address _to, uint256 _value, bytes _data) internal {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value, _data);
    }

    function transferToContract(address _to, uint256 _value, bytes _data) internal {
        balances[msg.sender] = balances[msg.sender].sub( _value);
        balances[_to] = balances[_to].add( _value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value, _data);
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

                                                                                           
    function isContract(address _addr) returns (bool is_contract) {
          uint256 length;
          assembly {
                                                                                    
              length := extcodesize(_addr)
          }
          if(length>0) {
              return true;
          }
          else {
              return false;
          }
    }
}

contract ERC23StandardToken is ERC23BasicToken {
    mapping (address => mapping (address => uint256)) allowed;
    event Approval (address indexed owner, address indexed spender, uint256 value);

    function transferFrom(address _from, address _to, uint256 _value) {
        var _allowance = allowed[_from][msg.sender];

                                                                                                              
                                          

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) {

                                                                               
                                                                            
                                                                    
                                                                             
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract STRIMToken is ERC23StandardToken {

               
    string public constant name = "STRIM Token";
    string public constant symbol = "STR";
    uint256 public constant decimals = 18;
    uint256 public fundsFromPreSale;
    string public version = "0.4";
    bool public halted;                              
    bool public isFinalized;                                         
	mapping(address => uint256) exchangeRate;
    uint256 public fundingStartBlock;
    uint256 public fundingEndBlock;
    uint256 public constant tokenExchangeRatePreSale = 10000;                                             
    uint256 public constant tokenExchangeRateMile1 = 3000;                                                
    uint256 public constant tokenExchangeRateMile2 = 2000;                                                 
    uint256 public constant tokenExchangeRateMile3 = 1000;                                                   
    uint256 public constant tokenCreationMinMile1 = 10 * (10 ** 6) * 10 ** decimals;                                                                       
    uint256 public constant tokenCreationMinMile2 = 78 * (10 ** 6) * 10 ** decimals;                                                             
	uint256 public constant tokenCreationMaxCap = 168 * (10 ** 6) * 10 ** decimals;                           

                
    address public ethFundDeposit;                                          
    address public strFundDeposit;                                                        
    address public StrimTeam;                 

             
    event LogRefund(address indexed _to, uint256 _value);
    event CreateSTR(address indexed _to, uint256 _value);
    event Halt();             
    event Unhalt();               

    modifier onlyTeam() {
                                                
        require(msg.sender == StrimTeam);
        _;
    }

    modifier crowdsaleTransferLock() {
        require(isFinalized);
        _;
    }

    modifier whenNotHalted() {
                                           
        require(!halted);
        _;
    }

                  
    function STRIMToken(
        address _ethFundDeposit,
        address _strFundDeposit,
        uint256 _fundingStartBlock,
        uint256 _fundingEndBlock) {
        isFinalized = false;                                       
        halted = false;
        ethFundDeposit = _ethFundDeposit;
        strFundDeposit = _strFundDeposit;
        fundingStartBlock = _fundingStartBlock;
        fundingEndBlock = _fundingEndBlock;
        totalSupply = 0;
        StrimTeam = msg.sender;
        fundsFromPreSale = 0;
    }

                                             
    function() payable {
        buy();
    }

                                    
    function halt() onlyTeam {
        halted = true;
        Halt();
    }

    function unhalt() onlyTeam {
        halted = false;
        Unhalt();
    }

    function buy() payable {
        createTokens(msg.sender);
    }



                                                            
    function createTokens(address recipient) public payable whenNotHalted {
        require(!isFinalized);
        require(block.number >= fundingStartBlock);
        require(block.number <= fundingEndBlock);
		require (totalSupply < tokenCreationMaxCap);
        require(msg.value > 0);

        uint256 retRate = returnRate();

        uint256 tokens = msg.value.mul(retRate);                                                
        if (retRate == 10000) {
            fundsFromPreSale = fundsFromPreSale.add(tokens);
			exchangeRate[recipient]=0;                                                                                        
        } else {
		    exchangeRate[recipient]=retRate;
		}
        balances[recipient] = balances[recipient].add(tokens);                                       
        totalSupply = totalSupply.add(tokens);

        CreateSTR(msg.sender, tokens);                       
        Transfer(this, recipient, tokens);
    }

                                         
    function returnRate() public constant returns(uint256) {
        if (block.number < fundingStartBlock.add(5000)) {
            return tokenExchangeRatePreSale;
        } else if (totalSupply.sub(fundsFromPreSale) < tokenCreationMinMile1) {
            return tokenExchangeRateMile1;
        } else if (totalSupply.sub(fundsFromPreSale) < tokenCreationMinMile2) {
            return tokenExchangeRateMile2;
        } else {
            return tokenExchangeRateMile3;  
        }
    }

    function finalize() external onlyTeam{
        require(!isFinalized);                              
        require(totalSupply >= tokenCreationMinMile1);                                               
        require(block.number > fundingEndBlock || totalSupply >= tokenCreationMaxCap);                                                     

        uint256 strVal = totalSupply.div(2);
        balances[strFundDeposit] = strVal;                       
        CreateSTR(msg.sender, strVal);                       

                                      
        if (!ethFundDeposit.send(this.balance)) revert();                              
        if (!strFundDeposit.send(this.balance)) revert();                              
        isFinalized = true;
    }

    function sendPreSaleETH() external onlyTeam{        
        require(block.number > fundingStartBlock.add(5000));                                               
        require(fundsFromPreSale > 0);                                             

        uint256 ethFromPreSale = fundsFromPreSale.div(10000);                               
        fundsFromPreSale = 0;                                                 

        if (!ethFundDeposit.send(ethFromPreSale)) revert();                                                      

    }

                                                                                           
    function refund() external {
        require(!isFinalized);                                  
        require(block.number > fundingEndBlock);                                             
        require(totalSupply < tokenCreationMinMile1);                                
        require(msg.sender != strFundDeposit);                                  
        
        if (exchangeRate[msg.sender] > 0) {                                                                                          
		    uint256 strVal = balances[msg.sender];
            balances[msg.sender] = 0;                                      
            totalSupply = totalSupply.sub(strVal);              
       	    uint256 ethVal = strVal / exchangeRate[msg.sender];                                                                     
            LogRefund(msg.sender, ethVal);           
            if (!msg.sender.send(ethVal)) revert();                                                                        
		}
    }

    function transfer(address _to, uint256 _value, bytes _data) public crowdsaleTransferLock returns(bool success) {
        return super.transfer(_to, _value, _data);
    }

    function transfer(address _to, uint256 _value) public crowdsaleTransferLock {
        super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public crowdsaleTransferLock {
        super.transferFrom(_from, _to, _value);
    }
}