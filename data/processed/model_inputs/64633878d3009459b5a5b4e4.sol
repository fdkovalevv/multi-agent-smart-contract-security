contract Crowdsale {
  using SafeMath for uint256;

                               
                                      
  address public wallet;
                  
  address public addressOfTokenUsedAsReward;

  uint256 public price = 40;

  token tokenReward;

                                                    
  


                                                                            
                              
                            
                                  
  uint256 public weiRaised;

     
                                     
                                             
                                          
                                        
                                             
     
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale() {
                                                                 
    wallet = 0xDFD46b7e8aF013250A79c15d433d59CFA8829b42;
                                              
                                                
    addressOfTokenUsedAsReward = 0x1a7b00404b755FF80126f1D66a90f5aEDdEd25da;


    tokenReward = token(addressOfTokenUsedAsReward);
  }

  bool public started = false;

  function startSale(){
    if (msg.sender != wallet) throw;
    started = true;
  }

  function stopSale(){
    if(msg.sender != wallet) throw;
    started = false;
  }

  function setPrice(uint256 _price){
    if(msg.sender != wallet) throw;
    price = _price;
  }
  function changeWallet(address _wallet){
  	if(msg.sender != wallet) throw;
  	wallet = _wallet;
  }

                                                
  function () payable {
    buyTokens(msg.sender);
  }

                                      
  function buyTokens(address beneficiary) payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

                                        
    uint256 tokens = (weiAmount) * price;                    

                   
    weiRaised = weiRaised.add(weiAmount);
    
                                                                    
                                                                            

    tokenReward.transfer(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }

                                             
                                                         
  function forwardFunds() internal {
                                  
    if (!wallet.send(msg.value)) {
      throw;
    }
  }

                                                   
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = started;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  function withdrawTokens(uint256 _amount) {
    if(msg.sender!=wallet) throw;
    tokenReward.transfer(wallet,_amount);
  }
}