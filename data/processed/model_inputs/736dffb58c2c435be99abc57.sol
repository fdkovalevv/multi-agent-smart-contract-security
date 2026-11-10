contract FinalizeAgent {

  function isFinalizeAgent() public constant returns(bool) {
    return true;
  }

                                                             
    
                                                                          
                                                   
     
  function isSane() public constant returns (bool);

                                                                     
  function finalizeCrowdsale();

}

contract ReservedTokensFinalizeAgent is FinalizeAgent {
  using SafeMathLibExt for uint;
  CrowdsaleTokenExt public token;
  CrowdsaleExt public crowdsale;

  function ReservedTokensFinalizeAgent(CrowdsaleTokenExt _token, CrowdsaleExt _crowdsale) {
    token = _token;
    crowdsale = _crowdsale;
  }

                                            
  function isSane() public constant returns (bool) {
    return (token.releaseAgent() == address(this));
  }

                                                                     
  function finalizeCrowdsale() public {
    if(msg.sender != address(crowdsale)) {
      throw;
    }

                                                       
    uint tokensSold = crowdsale.tokensSold();

                                         
    for (var j = 0; j < token.reservedTokensDestinationsLen(); j++) {
      uint allocatedBonusInPercentage;
      uint percentsOfTokensUnit = token.getReservedTokensListValInPercentageUnit(token.reservedTokensDestinations(j));
      uint percentsOfTokensDecimals = token.getReservedTokensListValInPercentageDecimals(token.reservedTokensDestinations(j));
      if (percentsOfTokensUnit > 0) {
        allocatedBonusInPercentage = tokensSold * percentsOfTokensUnit / 10**percentsOfTokensDecimals / 100;
        tokensSold = tokensSold.plus(allocatedBonusInPercentage);
        token.mint(token.reservedTokensDestinations(j), allocatedBonusInPercentage);
      }
    }

                                     
    for (var i = 0; i < token.reservedTokensDestinationsLen(); i++) {
      uint allocatedBonusInTokens = token.getReservedTokensListValInTokens(token.reservedTokensDestinations(i));
      if (allocatedBonusInTokens > 0) {
        tokensSold = tokensSold.plus(allocatedBonusInTokens);
        token.mint(token.reservedTokensDestinations(i), allocatedBonusInTokens);
      }
    }

    token.releaseTokenTransfer();
  }

}