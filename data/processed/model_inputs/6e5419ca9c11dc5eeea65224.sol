contract QuasacoinTokenCrowdsale {
  using SafeMath for uint256;

                         
  QuasacoinToken public token;

                                                                            
  uint256 public startPreICOTime;
                            
  uint256 public startICOTime;
  uint256 public endTime;

                                      
  address public wallet;

                                                
  address public tokenOwner;

                                              
  uint256 public ratePreICO;
  uint256 public rateICO;

                                  
  uint256 public weiRaisedPreICO;
  uint256 public weiRaisedICO;

  uint256 public capPreICO;
  uint256 public capICO;

  mapping(address => bool) internal allowedMinters;

     
                                     
                                             
                                          
                                        
                                             
     
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function QuasacoinTokenCrowdsale() {
    token = QuasacoinToken(0x4dAeb4a06F70f4b1A5C329115731fE4b89C0B227);
    tokenOwner = 0x373ae730d8c4250b3d022a65ef998b8b7ab1aa53;
    wallet = 0x373ae730d8c4250b3d022a65ef998b8b7ab1aa53;

                                      
    startPreICOTime = 1515974400;
                                     
    startICOTime = 1518652800;
                                     
    endTime = 1522022400;
    
                                
    ratePreICO = 6000;

                            
    rateICO = 3000;

    capPreICO = 5000 ether;
    capICO = 50000 ether;
  }

                                                
  function () payable {
    buyTokens(msg.sender);
  }

                                      
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

                                           
    uint256 tokens;
    if(now < startICOTime) {  
      weiRaisedPreICO = weiRaisedPreICO.add(weiAmount);
      tokens = weiAmount * ratePreICO;
    } 
    else {
      weiRaisedICO = weiRaisedICO.add(weiAmount);
      tokens = weiAmount * rateICO;
    }

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

                                             
                                                         
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

                                                   
  function validPurchase() internal constant returns (bool) {
   
    if(now >= startPreICOTime && now < startICOTime) {
      return weiRaisedPreICO.add(msg.value) <= capPreICO;
    } else if(now >= startICOTime && now < endTime) {
      return weiRaisedICO.add(msg.value) <= capICO;
    } else
    return false;
  }

                                              
  function hasEnded() public constant returns (bool) {
    if(now < startPreICOTime)
      return false;
    else if(now >= startPreICOTime && now < startICOTime) {
      return weiRaisedPreICO >= capPreICO;
    } else if(now >= startICOTime && now < endTime) {
      return weiRaisedICO >= capICO;
    } else
      return true;
  }

  function returnTokenOwnership() public {
    require(msg.sender == tokenOwner);
    token.transferOwnership(tokenOwner);
  }

  function addMinter(address addr) {
    require(msg.sender == tokenOwner);
    allowedMinters[addr] = true;
  }
  function removeMinter(address addr) {
    require(msg.sender == tokenOwner);
    allowedMinters[addr] = false;
  }

  function mintProxyWithoutCap(address _to, uint256 _amount) public {
    require(allowedMinters[msg.sender]);
    token.mint(_to, _amount);
  }

  function mintProxy(address _to, uint256 _amount) public {
    require(allowedMinters[msg.sender]);
    require(now >= startPreICOTime && now < endTime);
    
    uint256 weiAmount;

    if(now < startICOTime) {
      weiAmount = _amount.div(ratePreICO);
      require(weiRaisedPreICO.add(weiAmount) <= capPreICO);
      weiRaisedPreICO = weiRaisedPreICO.add(weiAmount);
    } 
    else {
      weiAmount = _amount.div(rateICO);
      require(weiRaisedICO.add(weiAmount) <= capICO);
      weiRaisedICO = weiRaisedICO.add(weiAmount);
    }

    token.mint(_to, _amount);
    TokenPurchase(msg.sender, _to, weiAmount, _amount);
  }
}