contract ValidetherOracle {

                                                                    
  mapping (string => address) nameToAddress;
                                                                      
  mapping (address => string) addressToName;

  address admin;

  modifier onlyAdmin {
     if (msg.sender != admin) throw;
     _
  }

    
                        
    
  function ValidetherOracle() {
    admin = msg.sender;
  }

    
                                      
      
  function addInstitution(address institutionAddress, string institutionName) onlyAdmin {
    nameToAddress[institutionName] = institutionAddress;
    addressToName[institutionAddress] = institutionName;
  }

    
                                                                        
                                                                 
                                                                                            
      
  function getInstitutionByAddress(address institutionAddress) constant returns(string) {
    return addressToName[institutionAddress];
  }

    
                                                                        
                                                  
                                                                                                                                          
    
  function getInstitutionByName(string institutionName) constant returns(address) {
    return nameToAddress[institutionName];
  }

    
                                                            
                                                     
    
  function setNewAdmin(address newAdmin) onlyAdmin {
    admin = newAdmin;
  }

}