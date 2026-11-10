contract Ownable {
  address public owner;


     
                                                                                         
             
     
  function Ownable() {
    owner = msg.sender;
  }


     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract Crowdsale {
  using SafeMath for uint256;

                         
  MintableToken public token;

                                                                       
  uint256 public startBlock;
  uint256 public endBlock;

                                      
  address public wallet;

                                              
  uint256 public rate;

                                  
  uint256 public weiRaised;

     
                                     
                                             
                                          
                                        
                                             
     
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address _wallet) {
    require(_startBlock >= block.number);
    require(_endBlock >= _startBlock);
    require(_rate > 0);
    require(_wallet != 0x0);

    token = createTokenContract();
    startBlock = _startBlock;
    endBlock = _endBlock;
    rate = _rate;
    wallet = _wallet;
  }

                                  
                                                                         
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


                                                
  function () payable {
    buyTokens(msg.sender);
  }

                                      
  function buyTokens(address beneficiary) payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

                                           
    uint256 tokens = weiAmount.mul(rate);

                   
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

                                             
                                                         
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

                                                   
  function validPurchase() internal constant returns (bool) {
    uint256 current = block.number;
    bool withinPeriod = current >= startBlock && current <= endBlock;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

                                              
  function hasEnded() public constant returns (bool) {
    return block.number > endBlock;
  }


}

contract WhitelistedCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;

                                                                 
    mapping (address => bool) public whitelist;

    function addToWhitelist(address buyer) public onlyOwner {
        require(buyer != 0x0);
        whitelist[buyer] = true;
    }

                                           
    function isWhitelisted(address buyer) public constant returns (bool) {
        return whitelist[buyer];
    }

                                                                
                                                   
    function validPurchase() internal constant returns (bool) {
                                                                              
        return super.validPurchase() || (!hasEnded() && isWhitelisted(msg.sender));
    }

}

contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

                                                 
                                 
  function finalize() onlyOwner {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

                                      
                                              
  function finalization() internal {
    token.finishMinting();
  }



}

contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }

                                                              
                                                    
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

                                                   
                                              
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

contract MANACrowdsale is WhitelistedCrowdsale, CappedCrowdsale, FinalizableCrowdsale {

    uint256 public constant TOTAL_SHARE = 100;
    uint256 public constant CROWDSALE_SHARE = 40;
    uint256 public constant FOUNDATION_SHARE = 60;

                                                                   
    uint256 public preferentialRate;

                                                    
    mapping (address => uint256) public buyerRate;

                                               
    uint256 public initialRate;

                                           
    uint256 public endRate;

                                    
    MANAContinuousSale public continuousSale;

    event WalletChange(address wallet);

    event PreferentialRateChange(address indexed buyer, uint256 rate);

    event InitialRateChange(uint256 rate);

    event EndRateChange(uint256 rate);

    function MANACrowdsale()
        CappedCrowdsale(86206 ether)
        WhitelistedCrowdsale()
        FinalizableCrowdsale()
        Crowdsale(4170650, 4170680, 12083, 0x000fb8369677b3065de5821a86bc9551d5e5eab9)
    {
        initialRate = 12083;
        endRate = 7250;
        preferentialRate = 12083;

        continuousSale = createContinuousSaleContract();

        MANAToken(token).pause();
    }

    function createTokenContract() internal returns(MintableToken) {
        return new MANAToken();
    }

    function createContinuousSaleContract() internal returns(MANAContinuousSale) {
        return new MANAContinuousSale(rate, wallet, token);
    }

    function setBuyerRate(address buyer, uint256 rate) onlyOwner public {
        require(rate != 0);
        require(isWhitelisted(buyer));
        require(block.number < startBlock);

        buyerRate[buyer] = rate;

        PreferentialRateChange(buyer, rate);
    }

    function setInitialRate(uint256 rate) onlyOwner public {
        require(rate != 0);
        require(block.number < startBlock);

        initialRate = rate;

        InitialRateChange(rate);
    }

    function setEndRate(uint256 rate) onlyOwner public {
        require(rate != 0);
        require(block.number < startBlock);

        endRate = rate;

        EndRateChange(rate);
    }

    function getRate() internal returns(uint256) {
                                                                          
        if (buyerRate[msg.sender] != 0) {
            return buyerRate[msg.sender];
        }

                                                                                      
        if (isWhitelisted(msg.sender)) {
            return preferentialRate;
        }

                                                      
        uint256 elapsed = block.number - startBlock;
        uint256 rateRange = initialRate - endRate;
        uint256 blockRange = endBlock - startBlock;

        return initialRate.sub(rateRange.mul(elapsed).div(blockRange));
    }

                                        
    function buyTokens(address beneficiary) payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;
        uint256 updatedWeiRaised = weiRaised.add(weiAmount);

        uint256 rate = getRate();
                                               
        uint256 tokens = weiAmount.mul(rate);

                       
        weiRaised = updatedWeiRaised;

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    function setWallet(address _wallet) onlyOwner public {
        require(_wallet != 0x0);
        wallet = _wallet;
        continuousSale.setWallet(_wallet);
        WalletChange(_wallet);
    }

    function unpauseToken() onlyOwner {
        require(isFinalized);
        MANAToken(token).unpause();
    }

    function pauseToken() onlyOwner {
        require(isFinalized);
        MANAToken(token).pause();
    }


    function beginContinuousSale() onlyOwner public {
        require(isFinalized);

        token.transferOwnership(continuousSale);

        continuousSale.start();
        continuousSale.transferOwnership(owner);
    }

    function finalization() internal {
        uint256 totalSupply = token.totalSupply();
        uint256 finalSupply = TOTAL_SHARE.mul(totalSupply).div(CROWDSALE_SHARE);

                                         
        token.mint(wallet, FOUNDATION_SHARE.mul(finalSupply).div(TOTAL_SHARE));

                                                                           
                                                           
    }

}