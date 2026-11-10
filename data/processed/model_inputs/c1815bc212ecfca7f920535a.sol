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

contract COOSCrowdsales is Ownable{
      using SafeMath for uint256;
      
                                      
      Token public token;
      
                                         
      Vault public vault;
      
                                         
      uint256 public crowdSaleHardCap;
      
      
                                                                     
      struct TierInfo{
          uint256 hardcap;
          uint256 startTime;
          uint256 endTime;
          uint256 rate;
          uint8 bonusPercentage;
          uint256 weiRaised;
      }
      
                         
      TierInfo[] public tiers;
      
                     
      uint256 public totalFunding;
      
      uint8 public noOfTiers;
      
      uint256 public tokensSold;
    
                                                 
      bool public salesActive;
      
                                                       
      bool public saleEnded;
      
      bool public unspentCreditsWithdrawn;
      
                                                    
      bool contractPoweredUp = false;
      
                                  
      event SaleStopped(address _owner, uint256 time);
      
                                                
      event Finalized(address _owner, uint256 time);
    
        
                                       
                                               
                                            
                                          
                                               
       
     event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    
                   
    modifier _saleActive(){
        require(salesActive);
        _;
    }
  
     modifier nonZeroAddress(address _to) {
        require(_to != 0x0);
        _;
    }
    
    modifier nonZeroEth() {
        require(msg.value > 0);
        _;
    }
    
    modifier _saleEnded() {
        require(saleEnded);
        _;
    }
    
    modifier tiersEmpty(){
        require(noOfTiers==0);
        _;
    }
    
    function COOSCrowdsales(address _tokenToBeUsed, address _wallet)public nonZeroAddress(_tokenToBeUsed) nonZeroAddress(_wallet){
        token = Token(_tokenToBeUsed);
        vault = new Vault(_wallet);
    }
    
       
                                                                               
                                                                  
      
    function powerUpContract() external onlyOwner {
        
        require(!contractPoweredUp);
        
                                                       
        require(!salesActive);

                                                     
        require(token.balanceOf(this) >= crowdSaleHardCap);
        
                                                         
        require(noOfTiers>0 && tiers.length==noOfTiers);
      
                                   
        salesActive=true;
        
        contractPoweredUp = true;
    }
    
                                    
    function emergencyStop() public onlyOwner _saleActive{
        salesActive = false;
        saleEnded = true;    
        vault.close();
        SaleStopped(msg.sender, now);
    }
    
       
                                                                       
                                                      
     
    function finalize()public onlyOwner _saleActive{
        require(saleTimeOver());
        salesActive = false;
        saleEnded = true;
        vault.close();
        Finalized(msg.sender, now);
    }
    
                                                     
  function saleTimeOver() public view returns (bool) {
      if(noOfTiers==0){
                                                                                    
          return false;
      }
                                                              
    return now > tiers[noOfTiers-1].endTime;
  }
  
                                                                                         
  function withdrawFunds() public onlyOwner _saleEnded{
  
      vault.withdrawToWallet();
  }
  
     
                                                                                   
                                                        
                                                                   
                                                               
                                                                
                                                                               
                                                                                
                                                                                                                                                          
                                                    
    
  function setTiersInfo(uint8 _noOfTiers, uint256[] _startTimes, uint256[] _endTimes, uint256[] _hardCaps, uint256[] _rates, uint8[] _bonusPercentages)public onlyOwner tiersEmpty{
    
                                                                    
    require(_noOfTiers>=1 && _noOfTiers<=5);
    
                                                    
    require(_startTimes.length == _noOfTiers);
    require(_endTimes.length==_noOfTiers);
    require(_hardCaps.length==_noOfTiers);
    require(_rates.length==_noOfTiers);
    require(_bonusPercentages.length==_noOfTiers);
    
    noOfTiers = _noOfTiers;
    
    for(uint8 i=0;i<noOfTiers;i++){
        require(_hardCaps[i]>0);
        require(_endTimes[i]>_startTimes[i]);
        require(_rates[i]>0);
        require(_bonusPercentages[i]>0);
        if(i>0){
            
                                                                                   
            require(_hardCaps[i] > _hardCaps[i-1]);
            
                                                                          
            require(_startTimes[i]>_endTimes[i-1]);
            
            tiers.push(TierInfo({
                hardcap:_hardCaps[i].mul( 10 ** uint256(token.decimals())),
                startTime:_startTimes[i],
                endTime:_endTimes[i],
                rate:_rates[i],
                bonusPercentage:_bonusPercentages[i],
                weiRaised:0
            }));
        }
        else{
                                                                     
            require(_startTimes[i]>now);
          
            tiers.push(TierInfo({
                hardcap:_hardCaps[i].mul( 10 ** uint256(token.decimals())),                                                                                                    
                startTime:_startTimes[i],
                endTime:_endTimes[i],
                rate:_rates[i],
                bonusPercentage:_bonusPercentages[i],
                weiRaised:0
            }));
        }
    }
    crowdSaleHardCap = _hardCaps[noOfTiers-1].mul( 10 ** uint256(token.decimals()));
  }
    
       
                                                                    
                                                                            
      
   function ownerWithdrawUnspentCredits()public onlyOwner _saleEnded{
        require(!unspentCreditsWithdrawn);
        unspentCreditsWithdrawn = true;
        token.transfer(owner, token.balanceOf(this));
   }
   
                                        
   function()public payable{
       buyTokens(msg.sender);
   }
   
      
                                           
                                                                                    
     
   function buyTokens(address beneficiary)public _saleActive nonZeroEth nonZeroAddress(beneficiary) payable returns(bool){
       
       int8 currentTierIndex = getCurrentlyRunningTier();
       assert(currentTierIndex>=0);
       
       TierInfo storage currentlyRunningTier = tiers[uint256(currentTierIndex)];
       
                                                    
       require(tokensSold < currentlyRunningTier.hardcap);
       
       uint256 weiAmount = msg.value;
       
       uint256 tokens = weiAmount.mul(currentlyRunningTier.rate);
       
       uint256 bonusedTokens = applyBonus(tokens, currentlyRunningTier.bonusPercentage);
       
                                                                                           
       assert(tokensSold.add(bonusedTokens) <= currentlyRunningTier.hardcap);
       
       tokensSold = tokensSold.add(bonusedTokens);
       
       totalFunding = totalFunding.add(weiAmount);
       
       currentlyRunningTier.weiRaised = currentlyRunningTier.weiRaised.add(weiAmount);
       vault.deposit.value(msg.value)(msg.sender);
       token.transfer(beneficiary, bonusedTokens);
       TokenPurchase(msg.sender, beneficiary, weiAmount, bonusedTokens);
       
   }
   
     function applyBonus(uint256 tokens, uint8 percent) internal pure returns  (uint256 bonusedTokens) {
        uint256 tokensToAdd = tokens.mul(percent).div(100);
        return tokens.add(tokensToAdd);
    }
    
      
                                                               
                                               
        
   function getCurrentlyRunningTier()public view returns(int8){
      for(uint8 i=0;i<noOfTiers;i++){
          if(now>=tiers[i].startTime && now<tiers[i].endTime){
              return int8(i);
          }
      }   
      return -1;
   }
   
      
                                                                                                              
     
   function getFundingInfoForUser(address _user)public view nonZeroAddress(_user) returns(uint256){
       return vault.deposited(_user);
   }
   
      
}