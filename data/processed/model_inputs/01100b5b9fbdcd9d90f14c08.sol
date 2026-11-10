contract AidaICO {
                                
    AidaToken public AID = new AidaToken(this);
    using SafeMath for uint256;

                             
                                                                 
    uint256 public Rate_Eth = 920;                    
    uint256 public Tokens_Per_Dollar = 4;                         
    uint256 public Token_Price = Tokens_Per_Dollar.mul(Rate_Eth);                      

    uint256 constant bountyPart = 10;                                    
    uint256 constant partnersPart = 30;                                    
    uint256 constant teamPart = 200;                                  
    uint256 constant icoAndPOfPart = 760;                                                     
    bool public returnPeriodExpired = false;
    uint256 finishTime = 0;

                                
    address public Company;
    address public BountyFund;
    address public PartnersFund;
    address public TeamFund;
    address public Manager;                             
    address public Controller_Address1;                                                              
    address public Controller_Address2;                                                               
    address public Controller_Address3;                                                              
    address public Oracle;                  
    address public RefundManager;                          

                            
    enum StatusICO {
        Created,
        PreIcoStarted,
        PreIcoPaused,
        PreIcoFinished,
        IcoStarted,
        IcoPaused,
        IcoFinished
    }

    StatusICO statusICO = StatusICO.Created;

               
    mapping(address => uint256) public ethPreIco;                                                               
    mapping(address => uint256) public ethIco;                                                            
    mapping(address => bool) public used;                                         
    mapping(address => uint256) public tokensPreIco;                                                                           
    mapping(address => uint256) public tokensIco;                                                                        
    mapping(address => uint256) public tokensPreIcoInOtherCrypto;                                                                                             
    mapping(address => uint256) public tokensIcoInOtherCrypto;                                                                                          

                 
    event LogStartPreICO();
    event LogPausePreICO();
    event LogFinishPreICO();
    event LogStartICO();
    event LogPauseICO();
    event LogFinishICO(address bountyFund, address partnersFund, address teamFund);
    event LogBuyForInvestor(address investor, uint256 aidValue, string txHash);
    event LogReturnEth(address investor, uint256 eth);
    event LogReturnOtherCrypto(address investor, string logString);

                
                                                  
    modifier refundManagerOnly {
        require(msg.sender == RefundManager);
        _;
    }
                                          
    modifier oracleOnly {
        require(msg.sender == Oracle);
        _;
    }
                                                    
    modifier managerOnly {
        require(msg.sender == Manager);
        _;
    }
                                                      
    modifier controllersOnly {
      require((msg.sender == Controller_Address1)
           || (msg.sender == Controller_Address2)
           || (msg.sender == Controller_Address3));
      _;
    }


      
                                          
      
    function AidaICO(
        address _Company,
        address _BountyFund,
        address _PartnersFund,
        address _TeamFund,
        address _Manager,
        address _Controller_Address1,
        address _Controller_Address2,
        address _Controller_Address3,
        address _Oracle,
        address _RefundManager
    )
        public {
        Company = _Company;
        BountyFund = _BountyFund;
        PartnersFund = _PartnersFund;
        TeamFund = _TeamFund;
        Manager = _Manager;
        Controller_Address1 = _Controller_Address1;
        Controller_Address2 = _Controller_Address2;
        Controller_Address3 = _Controller_Address3;
        Oracle = _Oracle;
        RefundManager = _RefundManager;
    }

      
                                                   
                                              
      
    function setRate(uint256 _RateEth) external oracleOnly {
        Rate_Eth = _RateEth;
        Token_Price = Tokens_Per_Dollar.mul(Rate_Eth);
    }

      
                         
                                       
      
    function startPreIco() external managerOnly {
        require(statusICO == StatusICO.Created || statusICO == StatusICO.PreIcoPaused);
        statusICO = StatusICO.PreIcoStarted;
        LogStartPreICO();
    }

      
                         
                                      
      
    function pausePreIco() external managerOnly {
        require(statusICO == StatusICO.PreIcoStarted);
        statusICO = StatusICO.PreIcoPaused;
        LogPausePreICO();
    }
      
                          
                                        
      
    function finishPreIco() external managerOnly {
        require(statusICO == StatusICO.PreIcoStarted || statusICO == StatusICO.PreIcoPaused);
        statusICO = StatusICO.PreIcoFinished;
        LogFinishPreICO();
    }

      
                      
                                    
      
    function startIco() external managerOnly {
        require(statusICO == StatusICO.PreIcoFinished || statusICO == StatusICO.IcoPaused);
        statusICO = StatusICO.IcoStarted;
        LogStartICO();
    }

      
                      
                                   
      
    function pauseIco() external managerOnly {
        require(statusICO == StatusICO.IcoStarted);
        statusICO = StatusICO.IcoPaused;
        LogPauseICO();
    }

      
                                                                             
      
    function finishIco() external managerOnly {
        require(statusICO == StatusICO.IcoStarted || statusICO == StatusICO.IcoPaused);
        uint256 alreadyMinted = AID.totalSupply();               
        uint256 totalAmount = alreadyMinted.mul(1000).div(icoAndPOfPart);
        AID.mintTokens(BountyFund, bountyPart.mul(totalAmount).div(1000));
        AID.mintTokens(PartnersFund, partnersPart.mul(totalAmount).div(1000));
        AID.mintTokens(TeamFund, teamPart.mul(totalAmount).div(1000));
        statusICO = StatusICO.IcoFinished;
        finishTime = now;
        LogFinishICO(BountyFund, PartnersFund, TeamFund);
    }


      
                                                    
      
    function enableTokensTransfer() external managerOnly {
        AID.defrostTokens();
    }

       
                                                   
      
    function disableTokensTransfer() external managerOnly {
        require((statusICO != StatusICO.IcoFinished) || (now <= finishTime + 21 days));
        AID.frostTokens();
    }

      
                                                                                   
                                                               
      
    function() external payable {
        require(statusICO == StatusICO.PreIcoStarted || statusICO == StatusICO.IcoStarted);
        createTokensForEth(msg.sender, msg.value.mul(Token_Price));
        rememberEther(msg.value, msg.sender);
    }

      
                                                         
                                                            
                                                
      
    function rememberEther(uint256 _value, address _investor) internal {
        if (statusICO == StatusICO.PreIcoStarted) {
            ethPreIco[_investor] = ethPreIco[_investor].add(_value);
        }
        if (statusICO == StatusICO.IcoStarted) {
            ethIco[_investor] = ethIco[_investor].add(_value);
        }
    }

      
                                                                          
                                             
                                                
      
    function rememberTokensEth(uint256 _value, address _investor) internal {
        if (statusICO == StatusICO.PreIcoStarted) {
            tokensPreIco[_investor] = tokensPreIco[_investor].add(_value);
        }
        if (statusICO == StatusICO.IcoStarted) {
            tokensIco[_investor] = tokensIco[_investor].add(_value);
        }
    }

      
                                                                                             
                                             
                                                
      
    function rememberTokensOtherCrypto(uint256 _value, address _investor) internal {
        if (statusICO == StatusICO.PreIcoStarted) {
            tokensPreIcoInOtherCrypto[_investor] = tokensPreIcoInOtherCrypto[_investor].add(_value);
        }
        if (statusICO == StatusICO.IcoStarted) {
            tokensIcoInOtherCrypto[_investor] = tokensIcoInOtherCrypto[_investor].add(_value);
        }
    }

      
                                                                                 
                                                                 
                                                                   
                                                  
      
    function buyForInvestor(
        address _investor,
        uint256 _aidValue,
        string _txHash
    )
        external
        controllersOnly {
        require(statusICO == StatusICO.PreIcoStarted || statusICO == StatusICO.IcoStarted);
        createTokensForOtherCrypto(_investor, _aidValue);
        LogBuyForInvestor(_investor, _aidValue, _txHash);
    }

      
                                                                          
                                                                       
                                                  
      
    function createTokensForOtherCrypto(address _investor, uint256 _aidValue) internal {
        require(_aidValue > 0);
        uint256 bonus = getBonus(_aidValue);
        uint256 total = _aidValue.add(bonus);
        rememberTokensOtherCrypto(total, _investor);
        AID.mintTokens(_investor, total);
    }

      
                                                         
                                                                       
                                                  
      
    function createTokensForEth(address _investor, uint256 _aidValue) internal {
        require(_aidValue > 0);
        uint256 bonus = getBonus(_aidValue);
        uint256 total = _aidValue.add(bonus);
        rememberTokensEth(total, _investor);
        AID.mintTokens(_investor, total);
    }

      
                                                            
                                             
                                        
      
    function getBonus(uint256 _value)
        public
        constant
        returns(uint256)
    {
        uint256 bonus = 0;
        if (statusICO == StatusICO.PreIcoStarted) {
            bonus = _value.mul(15).div(100);
        }
        return bonus;
    }


     
                                         
     
   function startRefunds() external managerOnly {
        returnPeriodExpired = false;
   }

     
                                          
     
   function stopRefunds() external managerOnly {
        returnPeriodExpired = true;
   }


      
                                                                 
                                                        
                        
      
    function returnEther() public {
        require(!used[msg.sender]);
        require(!returnPeriodExpired);
        uint256 eth = 0;
        uint256 tokens = 0;
        if (statusICO == StatusICO.PreIcoStarted) {
            require(ethPreIco[msg.sender] > 0);
            eth = ethPreIco[msg.sender];
            tokens = tokensPreIco[msg.sender];
            ethPreIco[msg.sender] = 0;
            tokensPreIco[msg.sender] = 0;
        }
        if (statusICO == StatusICO.IcoStarted) {
            require(ethIco[msg.sender] > 0);
            eth = ethIco[msg.sender];
            tokens = tokensIco[msg.sender];
            ethIco[msg.sender] = 0;
            tokensIco[msg.sender] = 0;
        }
        used[msg.sender] = true;
        msg.sender.transfer(eth);
        AID.burnTokens(msg.sender, tokens);
        LogReturnEth(msg.sender, eth);
    }

      
                                                                        
                                                        
                                                               
                                                                      
      
    function returnOtherCrypto(
        address _investor,
        string _logString
    )
        external
        refundManagerOnly {
        uint256 tokens = 0;
        require(!returnPeriodExpired);
        if (statusICO == StatusICO.PreIcoStarted) {
            tokens = tokensPreIcoInOtherCrypto[_investor];
            tokensPreIcoInOtherCrypto[_investor] = 0;
        }
        if (statusICO == StatusICO.IcoStarted) {
            tokens = tokensIcoInOtherCrypto[_investor];
            tokensIcoInOtherCrypto[_investor] = 0;
        }
        AID.burnTokens(_investor, tokens);
        LogReturnOtherCrypto(_investor, _logString);
    }

      
                                                
      
    function withdrawEther() external managerOnly {
        require(statusICO == StatusICO.PreIcoFinished || statusICO == StatusICO.IcoFinished);
        Company.transfer(this.balance);
    }

}