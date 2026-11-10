contract FinalizeAgent {

  function isFinalizeAgent() public constant returns(bool) {
    return true;
  }

                                                             
    
                                                                          
                                                   
     
  function isSane() public constant returns (bool);

                                                                     
  function finalizeCrowdsale();

}

contract NullFinalizeAgentExt is FinalizeAgent {

  CrowdsaleExt public crowdsale;

  function NullFinalizeAgentExt(CrowdsaleExt _crowdsale) {
    crowdsale = _crowdsale;
  }

                                            
  function isSane() public constant returns (bool) {
    return true;
  }

                                                                     
  function finalizeCrowdsale() public {
  }

}