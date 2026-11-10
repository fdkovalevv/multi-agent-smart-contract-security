contract RedemptionContract {
  address public funder;                                            
  address public token;                             
  uint public exchangeRate;                                

  event Redemption(address redeemer, uint tokensDeposited, uint redemptionAmount);

  function RedemptionContract(address _token, uint _exchangeRate) {
    funder = msg.sender;
    token = _token;
    exchangeRate = _exchangeRate;
  }

  function () payable {
    require(msg.sender == funder);
  }

  function redeemTokens(uint amount) {
                                                                      
                                                             
    require(Token(token).transferFrom(msg.sender, this, amount));
    
    uint redemptionValue = amount / exchangeRate; 
    
    msg.sender.transfer(redemptionValue);
    
    Redemption(msg.sender, amount, redemptionValue);
  }

}