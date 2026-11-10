contract trustedChildRefund {

  DAO constant public mainDAO = DAO(0xbb9bc244d798123fde783fcc1c72d3bb8c189413);
  uint[] public trustedProposals = [7, 10, 16, 20, 23, 26, 27, 28, 29, 31, 34, 37, 39, 41, 44, 52, 54, 56, 57, 60, 61, 63, 64, 65, 66];
  mapping (uint => DAO) public whiteList;

     
                                                                      
    
  function trustedChildRefund() {
      for(uint i=0; i<trustedProposals.length; i++) {
          uint proposalId = trustedProposals[i];
          whiteList[proposalId] = DAO(mainDAO.getNewDAOAddress(proposalId));
      }
  }

     
                                                                                 
                                                  
    
  function requiredEndowment() constant returns (uint endowment) {
      uint sum = 0;
      for(uint i=0; i<trustedProposals.length; i++) {
          uint proposalId = trustedProposals[i];
          DAO childDAO = whiteList[proposalId];
          sum += childDAO.totalSupply();
      }
      return sum;
  }

     
                                                            
                                                                       
                                                                                                              
     
  function refund(uint proposalId) {
                             
    uint balance = whiteList[proposalId].balanceOf(msg.sender);

                                                                     
    if (!whiteList[proposalId].transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
      throw;
  }

}