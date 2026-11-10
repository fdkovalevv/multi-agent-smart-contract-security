contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }


     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


     
                                                                                    
     
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

     
                                                                                
     
  modifier whenPaused() {
    require(paused);
    _;
  }

     
                                                              
     
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

     
                                                                 
     
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract MagnusSale is Ownable, Pausable {
    using SafeMath for uint256;

                                                 
    MagnusCoin internal token;

                                                          
    uint256 public start;                                                                                                                       
    uint256 public end;                                                                                                                       

    uint256 public minFundingGoalWei;                                                                                 
    uint256 public minContributionWei;                                                                                             
    uint256 public maxContributionWei;                                                                                             

    uint256 internal weiRaised;                                          

    uint256 public peggedETHUSD;                                              
    uint256 public hardCap;                                                                           
    uint256 internal reservedTokens;                                                                                                                        
    uint256 public baseRateInCents;                          

    mapping (address => uint256) public contributions;

    uint256 internal fiatCurrencyRaisedInEquivalentWeiValue = 0;                                             
    uint256 public weiRaisedIncludingFiatCurrencyRaised;                                                            
    bool internal isPresale;                                        
    bool public isRefunding = false;    


    address internal multiFirstWallet=0x9B7eDe5f815551279417C383779f1E455765cD6E;
    address internal multiSecondWallet=0x377Cc6d225cc49E450ee192d679950665Ae22e2C;
    address internal multiThirdWallet=0xD0377e0dC9334124803E38CBf92eFdDB7A43caC8;



    event ContributionReceived(address indexed buyer, bool presale, uint256 rate, uint256 value, uint256 tokens);
    event PegETHUSD(uint256 pegETHUSD);
    

    function MagnusSale(
    ) public {
        
        peggedETHUSD = 1210;
        address _token=0x1a7CC52cA652Ac5df72A7fA4b131cB9312dD3423;
        hardCap = 40000000000000000000000;
        reservedTokens = 0;
        isPresale = false;
        minFundingGoalWei  = 1000000000000000000000;
        minContributionWei = 300000000000000000;
        maxContributionWei = 10000000000000000000000;
        baseRateInCents = 42;
        start = 1517144812;
        uint256 _durationHours=4400;

        token = MagnusCoin(_token);
        
        end = start.add(_durationHours.mul(1 hours));


    }

    

    function() public payable whenNotPaused {
        require(!isRefunding);
        require(msg.sender != 0x0);
        require(msg.value >= minContributionWei);
        require(start <= now && end >= now);

                                                                                
        uint256 _weiContributionAllowed = maxContributionWei > 0 ? maxContributionWei.sub(contributions[msg.sender]) : msg.value;
        if (maxContributionWei > 0) {
            require(_weiContributionAllowed > 0);
        }

                                                        
        uint256 _tokensRemaining = token.balanceOf(address(this)).sub( reservedTokens );
        require(_tokensRemaining > 0);

                                                                         
        uint256 _weiContribution = msg.value;
        if (_weiContribution > _weiContributionAllowed) {
            _weiContribution = _weiContributionAllowed;
        }

                                                                  
        if (hardCap > 0 && weiRaised.add(_weiContribution) > hardCap) {
            _weiContribution = hardCap.sub( weiRaised );
        }

                                               
        uint256 _tokens = _weiContribution.mul(peggedETHUSD).mul(100).div(baseRateInCents);

        if (_tokens > _tokensRemaining) {
                                                                                                                 
            _tokens = _tokensRemaining;
            _weiContribution = _tokens.mul(baseRateInCents).div(100).div(peggedETHUSD);
            
        }

                                                                       
        contributions[msg.sender] = contributions[msg.sender].add(_weiContribution);

        ContributionReceived(msg.sender, isPresale, baseRateInCents, _weiContribution, _tokens);

        require(token.transfer(msg.sender, _tokens));

        weiRaised = weiRaised.add(_weiContribution);                                
        weiRaisedIncludingFiatCurrencyRaised = weiRaisedIncludingFiatCurrencyRaised.add(_weiContribution);


    }


    function pegETHUSD(uint256 _peggedETHUSD) onlyOwner public {
        peggedETHUSD = _peggedETHUSD;
        PegETHUSD(peggedETHUSD);
    }

    function setMinWeiAllowed( uint256 _minWeiAllowed ) onlyOwner public {
        minContributionWei = _minWeiAllowed;
    }

    function setMaxWeiAllowed( uint256 _maxWeiAllowed ) onlyOwner public {
        maxContributionWei = _maxWeiAllowed;
    }


    function setSoftCap( uint256 _softCap ) onlyOwner public {
        minFundingGoalWei = _softCap;
    }

    function setHardCap( uint256 _hardCap ) onlyOwner public {
        hardCap = _hardCap;
    }

    function peggedETHUSD() constant onlyOwner public returns(uint256) {
        return peggedETHUSD;
    }

    function hardCapETHInWeiValue() constant onlyOwner public returns(uint256) {
        return hardCap;
    }


    function totalWeiRaised() constant onlyOwner public returns(uint256) {
        return weiRaisedIncludingFiatCurrencyRaised;
    }


    function ownerTransferWeiFirstWallet(uint256 _value) external onlyOwner {
        require(multiFirstWallet != 0x0);
        require(multiFirstWallet != address(token));

                                                                                    
        uint256 _amount = _value > 0 ? _value : this.balance;

        multiFirstWallet.transfer(_amount);
    }

    function ownerTransferWeiSecondWallet(uint256 _value) external onlyOwner {
        require(multiSecondWallet != 0x0);
        require(multiSecondWallet != address(token));

                                                                                    
        uint256 _amount = _value > 0 ? _value : this.balance;

        multiSecondWallet.transfer(_amount);
    }

    function ownerTransferWeiThirdWallet(uint256 _value) external onlyOwner {
        require(multiThirdWallet != 0x0);
        require(multiThirdWallet != address(token));

                                                                                    
        uint256 _amount = _value > 0 ? _value : this.balance;

        multiThirdWallet.transfer(_amount);
    }

    function ownerRecoverTokens(address _beneficiary) external onlyOwner {
        require(_beneficiary != 0x0);
        require(_beneficiary != address(token));
        require(paused || now > end);

        uint256 _tokensRemaining = token.balanceOf(address(this));
        if (_tokensRemaining > 0) {
            token.transfer(_beneficiary, _tokensRemaining);
        }
    }

    
    function addFiatCurrencyRaised( uint256 _fiatCurrencyIncrementInEquivalentWeiValue ) onlyOwner public {
        fiatCurrencyRaisedInEquivalentWeiValue = fiatCurrencyRaisedInEquivalentWeiValue.add( _fiatCurrencyIncrementInEquivalentWeiValue);
        weiRaisedIncludingFiatCurrencyRaised = weiRaisedIncludingFiatCurrencyRaised.add(_fiatCurrencyIncrementInEquivalentWeiValue);
        
    }

    function reduceFiatCurrencyRaised( uint256 _fiatCurrencyDecrementInEquivalentWeiValue ) onlyOwner public {
        fiatCurrencyRaisedInEquivalentWeiValue = fiatCurrencyRaisedInEquivalentWeiValue.sub(_fiatCurrencyDecrementInEquivalentWeiValue);
        weiRaisedIncludingFiatCurrencyRaised = weiRaisedIncludingFiatCurrencyRaised.sub(_fiatCurrencyDecrementInEquivalentWeiValue);
    }

}