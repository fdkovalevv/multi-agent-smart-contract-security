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

contract LifMarketValidationMechanism is Ownable {
  using SafeMath for uint256;

                           
  LifToken public lifToken;

                                                                             
                                                                               
                                                                           
  address public foundationAddr;

                                                      
  uint256 public initialWei;

                                                                               
  uint256 public startTimestamp;

                                                                       
  uint256 public secondsPerPeriod;

                                                                              
  uint8 public totalPeriods;

                                                                      
  uint256 public totalWeiClaimed = 0;

                                                                            
  uint256 public initialBuyPrice = 0;

                                                 
  uint256 public totalBurnedTokens = 0;

                                                           
  uint256 public totalReimbursedWei = 0;

                                                    
  uint256 public originalTotalSupply;

  uint256 constant PRICE_FACTOR = 100000;

                                                                          
  bool public funded = false;

                                       
  bool public paused = false;

                                                    
  uint256 public totalPausedSeconds = 0;

                                           
  uint256 public pausedTimestamp;

  uint256[] public periods;

           
  event Pause();
  event Unpause(uint256 pausedSeconds);

  event ClaimedWei(uint256 claimedWei);
  event SentTokens(address indexed sender, uint256 price, uint256 tokens, uint256 returnedWei);

  modifier whenNotPaused(){
    assert(!paused);
    _;
  }

  modifier whenPaused(){
    assert(paused);
    _;
  }

     
                     

                                         
                                                
                                                    
                                            
                                                
      
  function LifMarketValidationMechanism(
    address lifAddr, uint256 _startTimestamp, uint256 _secondsPerPeriod,
    uint8 _totalPeriods, address _foundationAddr
  ) {
    require(lifAddr != address(0));
    require(_startTimestamp > block.timestamp);
    require(_secondsPerPeriod > 0);
    require(_totalPeriods == 24 || _totalPeriods == 48);
    require(_foundationAddr != address(0));

    lifToken = LifToken(lifAddr);
    startTimestamp = _startTimestamp;
    secondsPerPeriod = _secondsPerPeriod;
    totalPeriods = _totalPeriods;
    foundationAddr = _foundationAddr;

  }

     
                                                                         
                                                  
      
  function fund() public payable onlyOwner {
    assert(!funded);

    originalTotalSupply = lifToken.totalSupply();
    initialWei = msg.value;
    initialBuyPrice = initialWei.
      mul(PRICE_FACTOR).
      div(originalTotalSupply);

    funded = true;
  }

     
                                                                               
                                                                              
                                                                              
      
  function calculateDistributionPeriods() public {
    assert(totalPeriods == 24 || totalPeriods == 48);
    assert(periods.length == 0);

                                                                                   
                                                                                 
                                                                   
                                                                            
                                                                                     
                                                                                    

    uint256[24] memory accumDistribution24 = [
      uint256(0), 18, 117, 351, 767, 1407,
      2309, 3511, 5047, 6952, 9257, 11995,
      15196, 18889, 23104, 27870, 33215, 39166,
      45749, 52992, 60921, 69561, 78938, 89076
    ];

    uint256[48] memory accumDistribution48 = [
      uint256(0), 3, 18, 54, 117, 214, 351, 534,
      767, 1056, 1406, 1822, 2308, 2869, 3510, 4234,
      5046, 5950, 6950, 8051, 9256, 10569, 11994, 13535,
      15195, 16978, 18888, 20929, 23104, 25416, 27870, 30468,
      33214, 36112, 39165, 42376, 45749, 49286, 52992, 56869,
      60921, 65150, 69560, 74155, 78937, 83909, 89075, 94438
    ];

    for (uint8 i = 0; i < totalPeriods; i++) {

      if (totalPeriods == 24) {
        periods.push(accumDistribution24[i]);
      } else {
        periods.push(accumDistribution48[i]);
      }

    }
  }

     
                                                                       

                                                                  
      
  function getCurrentPeriodIndex() public view returns(uint256) {
    assert(block.timestamp >= startTimestamp);
    return block.timestamp.sub(startTimestamp).
      sub(totalPausedSeconds).
      div(secondsPerPeriod);
  }

     
                                                                       
                                                 

                                                                              
                                                                  
      
  function getAccumulatedDistributionPercentage() public view returns(uint256 percentage) {
    uint256 period = getCurrentPeriodIndex();

    assert(period < totalPeriods);

    return periods[period];
  }

     
                                                                                
              

                                                                           
      
  function getBuyPrice() public view returns (uint256 price) {
    uint256 accumulatedDistributionPercentage = getAccumulatedDistributionPercentage();

    return initialBuyPrice.
      mul(PRICE_FACTOR.sub(accumulatedDistributionPercentage)).
      div(PRICE_FACTOR);
  }

     
                                                                               
                                                               

                                                                  
      
  function getMaxClaimableWeiAmount() public view returns (uint256) {
    if (isFinished()) {
      return this.balance;
    } else {
      uint256 claimableFromReimbursed = initialBuyPrice.
        mul(totalBurnedTokens).div(PRICE_FACTOR).
        sub(totalReimbursedWei);
      uint256 currentCirculation = lifToken.totalSupply();
      uint256 accumulatedDistributionPercentage = getAccumulatedDistributionPercentage();
      uint256 maxClaimable = initialWei.
        mul(accumulatedDistributionPercentage).div(PRICE_FACTOR).
        mul(currentCirculation).div(originalTotalSupply).
        add(claimableFromReimbursed);

      if (maxClaimable > totalWeiClaimed) {
        return maxClaimable.sub(totalWeiClaimed);
      } else {
        return 0;
      }
    }
  }

     
                                                                          
                                                     
      
  function sendTokens(uint256 tokens) public whenNotPaused {
    require(tokens > 0);

    uint256 price = getBuyPrice();
    uint256 totalWei = tokens.mul(price).div(PRICE_FACTOR);

    lifToken.transferFrom(msg.sender, address(this), tokens);
    lifToken.burn(tokens);
    totalBurnedTokens = totalBurnedTokens.add(tokens);

    SentTokens(msg.sender, price, tokens, totalWei);

    totalReimbursedWei = totalReimbursedWei.add(totalWei);
    msg.sender.transfer(totalWei);
  }

     
                                                                         
                                                                               
                                             

                                                         
      
  function isFinished() public view returns (bool finished) {
    return getCurrentPeriodIndex() >= totalPeriods;
  }

     
                                                                           
                                                        
                             
      
  function claimWei(uint256 weiAmount) public whenNotPaused {
    require(msg.sender == foundationAddr);

    uint256 claimable = getMaxClaimableWeiAmount();

    assert(claimable >= weiAmount);

    foundationAddr.transfer(weiAmount);

    totalWeiClaimed = totalWeiClaimed.add(weiAmount);

    ClaimedWei(weiAmount);
  }

     
                                                                            
                                                                             
                           
      
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    pausedTimestamp = block.timestamp;

    Pause();
  }

     
                                                                      
      
  function unpause() public onlyOwner whenPaused {
    uint256 pausedSeconds = block.timestamp.sub(pausedTimestamp);
    totalPausedSeconds = totalPausedSeconds.add(pausedSeconds);
    paused = false;

    Unpause(pausedSeconds);
  }

}