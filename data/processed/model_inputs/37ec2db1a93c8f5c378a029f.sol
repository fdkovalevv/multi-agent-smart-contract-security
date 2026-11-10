contract PricingStrategy {

                               
  function isPricingStrategy() public constant returns (bool) {
    return true;
  }

                                                     
    
                                                               
     
  function isSane(address crowdsale) public constant returns (bool) {
    return true;
  }

     
                                                             
                                              
                                                          
     
  function isPresalePurchase(address purchaser) public constant returns (bool) {
    return false;
  }

     
                                                                                     
    
    
                                                                       
                                                                
                                                                                                                     
                                                               
                                                           
                                                   
     
  function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint tokenAmount);
}

contract FlatPricing is PricingStrategy {

  using SafeMathLib for uint;

                                     
  uint public oneTokenInWei;

  function FlatPricing(uint _oneTokenInWei) {
    require(_oneTokenInWei > 0);
    oneTokenInWei = _oneTokenInWei;
  }

     
                                                   
    
     
  function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint) {
    uint multiplier = 10 ** decimals;
    return value.times(multiplier) / oneTokenInWei;
  }

}