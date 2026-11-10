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

contract Crowdsale {
  using SafeMath for uint256;

                         
  MintableToken public token;

                                                                            
  uint256 public startTime;
  uint256 public endTime;

                                      
  address public wallet;

                                              
  uint256 public rate;

                                  
  uint256 public weiRaised;

     
                                     
                                             
                                          
                                        
                                             
     
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

                                                
  function () external payable {
    buyTokens(msg.sender);
  }

                                      
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

                                           
    uint256 tokens = getTokenAmount(weiAmount);

                   
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

                                              
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }

                                  
                                                                         
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }

                                                                                           
  function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
    return weiAmount.mul(rate);
  }

                                             
                                                         
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

                                                   
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

}

contract IcoCrowdsale is Crowdsale, Ownable {
                       
                                             
    uint256 public constant MAX_TOKEN_CAP = 13e6 * 1e18;                            

                                          
    uint256 public constant ICO_ENABLERS_CAP = 15e5 * 1e18;                          
    uint256 public constant DEVELOPMENT_TEAM_CAP = 2e6 * 1e18;                     
    uint256 public constant ICO_TOKEN_CAP = 9.5e6 * 1e18;                              

    uint256 public constant CHF_CENT_PER_TOKEN = 1000;                                                                              
    uint256 public constant MIN_CONTRIBUTION_CHF = 250;

    uint256 public constant VESTING_CLIFF = 1 years;
    uint256 public constant VESTING_DURATION = 3 years;

                                                                                                  
    uint256 public constant DISCOUNT_TOKEN_AMOUNT_T1 = 3e6 * 1e18;                    
    uint256 public constant DISCOUNT_TOKEN_AMOUNT_T2 = DISCOUNT_TOKEN_AMOUNT_T1 * 2;

                                                            
    uint256 public tokensToMint;                                                     
    uint256 public tokensMinted;                                                      
    uint256 public icoEnablersTokensMinted;
    uint256 public developmentTeamTokensMinted;

    uint256 public minContributionInWei;
    uint256 public tokenPerWei;
    uint256 public totalTokensPurchased;
    bool public capReached;
    bool public tier1Reached;
    bool public tier2Reached;

    address public underwriter;

                                                                                
                                                                                        
    mapping(address => bool) public isManager;

                                              
    mapping(address => bool) public isBlacklisted;

    uint256 public confirmationPeriod;
    bool public confirmationPeriodOver;                                                                   

                                               
    address[] public vestingWallets;

    uint256 public investmentIdLastAttemptedToSettle;

    struct Payment {
        address investor;
        address beneficiary;
        uint256 weiAmount;
        uint256 tokenAmount;
        bool confirmed;
        bool attemptedSettlement;
        bool completedSettlement;
    }

    Payment[] public investments;

                    
    event ChangedInvestorBlacklisting(address investor, bool blacklisted);
    event ChangedManager(address manager, bool active);
    event ChangedInvestmentConfirmation(uint256 investmentId, address investor, bool confirmed);

                       
    modifier onlyUnderwriter() {
        require(msg.sender == underwriter);
        _;
    }

    modifier onlyManager() {
        require(isManager[msg.sender]);
        _;
    }

    modifier onlyNoneZero(address _to, uint256 _amount) {
        require(_to != address(0));
        require(_amount > 0);
        _;
    }

    modifier onlyConfirmPayment() {
        require(now > endTime && now <= endTime.add(confirmationPeriod));
        require(!confirmationPeriodOver);
        _;
    }

    modifier onlyConfirmationOver() {
        require(confirmationPeriodOver || now > endTime.add(confirmationPeriod));
        _;
    }

       
                                                
                                                            
                                                        
                                                     
                                                             
                                                                         
                                                     
       
    function IcoCrowdsale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rateChfPerEth,
        address _wallet,
        uint256 _confirmationPeriodDays,
        address _underwriter
    )
        public
        Crowdsale(_startTime, _endTime, _rateChfPerEth, _wallet)
    {
        require(MAX_TOKEN_CAP == ICO_ENABLERS_CAP.add(ICO_TOKEN_CAP).add(DEVELOPMENT_TEAM_CAP));
        require(_underwriter != address(0));

        setManager(msg.sender, true);

        tokenPerWei = (_rateChfPerEth.mul(1e2)).div(CHF_CENT_PER_TOKEN);
        minContributionInWei = (MIN_CONTRIBUTION_CHF.mul(1e18)).div(_rateChfPerEth);

        confirmationPeriod = _confirmationPeriodDays * 1 days;
        underwriter = _underwriter;
    }

       
                                                                                       
                                                                     
                                                                           
       
    function setManager(address _manager, bool _active) public onlyOwner {
        isManager[_manager] = _active;
        ChangedManager(_manager, _active);
    }

       
                                                                  
                                                                                   
       
    function blackListInvestor(address _investor, bool _active) public onlyManager {
        isBlacklisted[_investor] = _active;
        ChangedInvestorBlacklisting(_investor, _active);
    }

       
                                                                                              
                                                                             
                                                                                                              
       
    function buyTokens(address _beneficiary) public payable {
        require(_beneficiary != address(0));
        require(validPurchase());
        require(!isBlacklisted[msg.sender]);

        uint256 weiAmount = msg.value;
        uint256 tokenAmount;
        uint256 purchasedTokens = weiAmount.mul(tokenPerWei);
        uint256 tempTotalTokensPurchased = totalTokensPurchased.add(purchasedTokens);
        uint256 overflowTokens;
        uint256 overflowTokens2;
                                    
        uint256 tier1BonusTokens;
                                    
        uint256 tier2BonusTokens;

                                                               
        if (!tier1Reached) {

                                                                                                                              
            if (tempTotalTokensPurchased > DISCOUNT_TOKEN_AMOUNT_T1) {
                tier1Reached = true;
                overflowTokens = tempTotalTokensPurchased.sub(DISCOUNT_TOKEN_AMOUNT_T1);
                tier1BonusTokens = purchasedTokens.sub(overflowTokens);
                                                                         
            } else {
                tier1BonusTokens = purchasedTokens;
            }
                            
            tier1BonusTokens = tier1BonusTokens.mul(10).div(8);
            tokenAmount = tokenAmount.add(tier1BonusTokens);
        }

                                                               
        if (tier1Reached && !tier2Reached) {

                                                                                                                      
            if (tempTotalTokensPurchased > DISCOUNT_TOKEN_AMOUNT_T2) {
                tier2Reached = true;
                overflowTokens2 = tempTotalTokensPurchased.sub(DISCOUNT_TOKEN_AMOUNT_T2);
                tier2BonusTokens = purchasedTokens.sub(overflowTokens2);
                                                                                  
            } else {
                                                                             
                if (overflowTokens > 0) {
                    tier2BonusTokens = overflowTokens;
                } else {
                    tier2BonusTokens = purchasedTokens;
                }
            }
                                               
            tier2BonusTokens = tier2BonusTokens.mul(10).div(9);
            tokenAmount = tokenAmount.add(tier2BonusTokens).add(overflowTokens2);
        }

                                                                                                                                                        
                             
        if (tier2Reached && tier1Reached && tier2BonusTokens == 0) {
            tokenAmount = purchasedTokens;
        }

                                                  
                                                           
        totalTokensPurchased = totalTokensPurchased.add(purchasedTokens);
                                                                                  
        tokensToMint = tokensToMint.add(tokenAmount);

        weiRaised = weiRaised.add(weiAmount);

        TokenPurchase(msg.sender, _beneficiary, weiAmount, tokenAmount);

                                                                                                       
        Payment memory newPayment = Payment(msg.sender, _beneficiary, weiAmount, tokenAmount, false, false, false);
        investments.push(newPayment);
    }

       
                            
                                                                           
       
    function confirmPayment(uint256 _investmentId) public onlyManager onlyConfirmPayment {
        investments[_investmentId].confirmed = true;
        ChangedInvestmentConfirmation(_investmentId, investments[_investmentId].investor, true);
    }

       
                                                
                                                                                        
       
    function batchConfirmPayments(uint256[] _investmentIds) public onlyManager onlyConfirmPayment {
        uint256 investmentId;

        for (uint256 c; c < _investmentIds.length; c = c.add(1)) {
            investmentId = _investmentIds[c];                    
            confirmPayment(investmentId);
        }
    }

       
                                                     
                                                                          
       
    function unConfirmPayment(uint256 _investmentId) public onlyManager onlyConfirmPayment {
        investments[_investmentId].confirmed = false;
        ChangedInvestmentConfirmation(_investmentId, investments[_investmentId].investor, false);
    }

      
                                                                                               
                                                                            
                                                                                                 
      
    function batchMintTokenDirect(address[] _toList, uint256[] _tokenList) public onlyOwner {
        require(_toList.length == _tokenList.length);

        for (uint256 i; i < _toList.length; i = i.add(1)) {
            mintTokenDirect(_toList[i], _tokenList[i]);
        }
    }

       
                                                                                     
                                                              
                                                         
       
    function mintTokenDirect(address _to, uint256 _tokens) public onlyOwner {
        require(tokensToMint.add(_tokens) <= ICO_TOKEN_CAP);

        tokensToMint = tokensToMint.add(_tokens);

                                                                                                       
        Payment memory newPayment = Payment(address(0), _to, 0, _tokens, false, false, false);
        investments.push(newPayment);
        TokenPurchase(msg.sender, _to, 0, _tokens);
    }

       
                                                                                                              
                                         
                                                  
       
    function mintIcoEnablersTokens(address _to, uint256 _tokens) public onlyOwner onlyNoneZero(_to, _tokens) {
        require(icoEnablersTokensMinted.add(_tokens) <= ICO_ENABLERS_CAP);

        token.mint(_to, _tokens);
        icoEnablersTokensMinted = icoEnablersTokensMinted.add(_tokens);
    }

       
                                                                                                                                          
                                         
                                                  
       
    function mintDevelopmentTeamTokens(address _to, uint256 _tokens) public onlyOwner onlyNoneZero(_to, _tokens) {
        require(developmentTeamTokensMinted.add(_tokens) <= DEVELOPMENT_TEAM_CAP);

        developmentTeamTokensMinted = developmentTeamTokensMinted.add(_tokens);
        TokenVesting newVault = new TokenVesting(_to, now, VESTING_CLIFF, VESTING_DURATION, false);
        vestingWallets.push(address(newVault));                                                                                                   
        token.mint(address(newVault), _tokens);
    }

       
                                                                 
       
    function getVestingWalletLength() public view returns (uint256) {
        return vestingWallets.length;
    }

       
                                             
       
    function finalizeConfirmationPeriod() public onlyOwner onlyConfirmPayment {
        confirmationPeriodOver = true;
    }

       
                                                           
                                                                   
       
    function settleInvestment(uint256 _investmentId) public onlyConfirmationOver {
        Payment storage p = investments[_investmentId];

                                                                                                
        require(!p.completedSettlement);

                                                          
                                                                                                             

        require(_investmentId == 0 || investments[_investmentId.sub(1)].attemptedSettlement);

        p.attemptedSettlement = true;

                                                                                              
        investmentIdLastAttemptedToSettle = _investmentId;

        if (p.confirmed && !capReached) {
                                                                                       

                                                                  
            uint256 tokens = p.tokenAmount;

                                                                                 
                            
            if (tokensMinted.add(tokens) > ICO_TOKEN_CAP) {
                capReached = true;
                if (p.weiAmount > 0) {
                    p.investor.send(p.weiAmount);                                                                 
                }
            } else {
                tokensToMint = tokensToMint.sub(tokens);
                tokensMinted = tokensMinted.add(tokens);

                                              
                token.mint(p.beneficiary, tokens);
                if (p.weiAmount > 0) {
                                                                             
                    wallet.transfer(p.weiAmount);
                }
            }

            p.completedSettlement = true;
        } else {
                                                                                          
                                                                        
                                                   
                                                                                        
            if (p.investor != address(0) && p.weiAmount > 0) {
                if (p.investor.send(p.weiAmount)) {
                    p.completedSettlement = true;
                }
            }
        }
    }

       
                                                           
                                                                         
       
    function batchSettleInvestments(uint256[] _investmentIds) public {
        for (uint256 c; c < _investmentIds.length; c = c.add(1)) {
            settleInvestment(_investmentIds[c]);
        }
    }

       
                                                                                                                                                
       
    function finalize() public onlyUnderwriter onlyConfirmationOver {
        Pausable(token).unpause();

                                                                           
        IcoToken(token).setTreasurer(this, false);

                                                        
        MintableToken(token).finishMinting();

                                                                      
                                                                                   
                                            
                                                                                     
        Ownable(token).transferOwnership(owner);
    }

       
                                                     
       
    function createTokenContract() internal returns (MintableToken) {
        return new IcoToken();
    }

       
                                                                
       
    function validPurchase() internal view returns (bool) {
                                                           
        require (msg.value >= minContributionInWei);
        return super.validPurchase();
    }
}