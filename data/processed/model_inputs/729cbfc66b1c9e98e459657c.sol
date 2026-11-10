contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
                                                                                         
             
     
  function Ownable() {
    owner = msg.sender;
  }

     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract GESTokenCrowdSale is Ownable {
  using SafeMath for uint256;

                                    
  bool public isFinalised;

                        
  MintableToken public token;

                                                                               
  uint256 public mainSaleStartTime;
  uint256 public mainSaleEndTime;

                                                            
  address public wallet;

                                                     
  address public tokenWallet;

                                                   
  uint256 public rate = 10000;

                                     
                                             
  uint256 public weiRaised = 1273779099000000000000 ;

                                                            

                                                                  
  uint256 public saleMinimumWei = 100000000000000000; 
  
                                                 
  uint256 public hardCap = 20000000000000000000000; 
  
                                                     
                                                                                        
                                                             
                                              
  uint256 public tokensToSell = 248585331 * 10 ** 18; 

                                                                      
   struct AmountBonus {
    uint256 amount;
    uint percent;
  }
  AmountBonus[] public amountBonuses;
     
                                     
                                       
     
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event FinalisedCrowdsale(uint256 totalSupply);

  function GESTokenCrowdSale(uint256 _mainSaleStartTime, uint256 _mainSaleEndTime, address _wallet, address _tokenWallet) public {

                                           
    require(_mainSaleStartTime >= now);
                                                       
    require(_mainSaleEndTime >= _mainSaleStartTime);

                                              
    require(_wallet != 0x0);
    require(_tokenWallet != 0x0);

                          
    token = createTokenContract();
    
    amountBonuses.push(AmountBonus(    50000000000000000000, 20));
    amountBonuses.push(AmountBonus(   100000000000000000000, 25));
    amountBonuses.push(AmountBonus(   250000000000000000000, 30));
    amountBonuses.push(AmountBonus(   500000000000000000000, 35));
    amountBonuses.push(AmountBonus(  1000000000000000000000, 40));
    amountBonuses.push(AmountBonus(  2500000000000000000000, 45));
    amountBonuses.push(AmountBonus(200000000000000000000000, 50));


    mainSaleStartTime = _mainSaleStartTime;
    mainSaleEndTime = _mainSaleEndTime;

    wallet = _wallet ;
    tokenWallet = _tokenWallet;

    isFinalised = false;

                                                                                                  
                                                                                   
                                                               
                                                               
                                                                  
    token.mint(tokenWallet, 51414669 * 10 ** 18);
  }

                                    
  function createTokenContract() internal returns (MintableToken) {
    return new GESToken();
  }

                                                   
  function () public payable {
    buyTokens(msg.sender);
  }

                                         
  function buyTokens(address beneficiary) public payable {
    require(!isFinalised);
    require(beneficiary != 0x0);
    require(msg.value != 0);
    require(now >= mainSaleStartTime && now <= mainSaleEndTime);
    uint256 newRaise = weiRaised.add(msg.value);
    require(msg.value >= saleMinimumWei && newRaise <= hardCap);

                                                  
    uint256 bonusedTokens = applyBonus(msg.value);
    
                                                   
    require(bonusedTokens < tokensToSell);

                                        
    weiRaised = newRaise;
    tokensToSell = tokensToSell.sub(bonusedTokens);
    token.mint(beneficiary, bonusedTokens);
    TokenPurchase(msg.sender, beneficiary, msg.value, bonusedTokens);
  }

                      
     
  function finaliseCrowdsale() external onlyOwner returns (bool) {
    require(!isFinalised);
    token.finishMinting();
    forwardFunds();
    FinalisedCrowdsale(token.totalSupply());
    isFinalised = true;
    return true;
  }

                                
  function pauseToken() external onlyOwner {
    require(!isFinalised);
    GESToken(token).pause();
  }

                                  
  function unpauseToken() external onlyOwner {
    GESToken(token).unpause();
  }

                                                          
  function transferTokenOwnership(address newOwner) external onlyOwner {
    GESToken(token).transferOwnership(newOwner);
  }

                                                 
  function mainSaleHasEnded() external constant returns (bool) {
    return now > mainSaleEndTime;
  }

                                                
  function forwardFunds() internal {
    wallet.transfer(this.balance);
  }

                                                    
  function setMainSaleDates(uint256 _mainSaleStartTime, uint256 _mainSaleEndTime) public onlyOwner returns (bool) {
    require(!isFinalised);
    require(_mainSaleStartTime < _mainSaleEndTime);
    mainSaleStartTime = _mainSaleStartTime;
    mainSaleEndTime = _mainSaleEndTime;
    return true;
  }

                                                                                      
  function applyBonus(uint256 weiAmount) internal constant returns (uint256 bonusedTokens) {
                                  
    uint256 tokensToAdd = 0;

                                                                                                
    uint256 tokens = weiAmount.mul(rate);
    
    for(uint8 i = 0; i < amountBonuses.length; i++){
        if(weiAmount < amountBonuses[i].amount){
           tokensToAdd = tokens.mul(amountBonuses[i].percent).div(100);
            return tokens.add(tokensToAdd);
        }
    }
                                                       
    return tokens.mul(120).div(100);
  }

      
                                                           
    
  function fetchFunds() onlyOwner public {
    wallet.transfer(this.balance);
  }

}