contract SoapBox {
                                                                 
                   
    mapping (address => bool) approvedSoapboxer;
    string opinion;
     
                                                           
	                 
 
    event OpinionBroadcast(address _soapboxer, string _opinion);
                                                                           
                          

    function SoapBox() public {
    }
    
                                                                                                       
	                                   
    function() public payable{
                                                                                    
		                        
        if (msg.value > 20000000000000000) {  
                                                                
			                            
                                                                  
			                                
            approvedSoapboxer[msg.sender] =  true;
        }
    }
    
    
                                                                                                     
	                             
    function isApproved(address _soapboxer) public view returns (bool approved) {
        return approvedSoapboxer[_soapboxer];
    } 
    
                                                          
	              
    function getCurrentOpinion() public view returns(string) {
        return opinion;
    }
                                                        
                    
    function broadcastOpinion(string _opinion) public returns (bool success) {
                                                                                              
		                             
        if (approvedSoapboxer[msg.sender]) {
            
            opinion = _opinion;
            emit OpinionBroadcast(msg.sender, opinion);
            return true;
            
        } else {
            return false;
        }
        
    }
}