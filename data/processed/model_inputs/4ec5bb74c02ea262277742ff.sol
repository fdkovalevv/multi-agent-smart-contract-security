contract untrustedChildWithdraw {

  struct childDAO {
	  DAO dao;
    uint numerator;
	}

  DAO constant public mainDAO = DAO(0xbb9bc244d798123fde783fcc1c72d3bb8c189413);
  uint[] public untrustedProposals = [35, 36, 53, 62, 67, 68, 70, 71, 73, 76, 87];
  uint public ratioDenominator = 1000000000;
  uint[] public untrustedTokenNumerator = [1458321331, 1458321331, 1399760834, 1457994374, 1457994374, 1146978827, 1457994374, 1458321336, 1458307000, 1458328768, 1458376290];
  mapping (uint => childDAO) public whiteList;

     
                                                                      
    
  function untrustedChildWithdraw() {
      for(uint i=0; i<untrustedProposals.length; i++) {
          uint proposalId = untrustedProposals[i];
          whiteList[proposalId] = childDAO(DAO(mainDAO.getNewDAOAddress(proposalId)), untrustedTokenNumerator[i]);
      }
  }

     
                                                                                 
                                                  
    
  function requiredEndowment() constant returns (uint endowment) {
      uint sum = 0;
      for(uint i=0; i<untrustedProposals.length; i++) {
          uint proposalId = untrustedProposals[i];
          DAO child = whiteList[proposalId].dao;
          sum += (child.totalSupply() * (untrustedTokenNumerator[i] / ratioDenominator) );
      }
      return sum;
  }

     
                                                              
                                                                       
                                                                                                              
     
  function withdraw(uint proposalId) {
                             
    uint balance = whiteList[proposalId].dao.balanceOf(msg.sender);
    uint adjustedBalance = balance * (whiteList[proposalId].numerator / ratioDenominator);

                                                                     
    if (!whiteList[proposalId].dao.transferFrom(msg.sender, this, balance) || !msg.sender.send(adjustedBalance))
      throw;
  }

}