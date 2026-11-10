contract DeltaBalances {
	
	address public admin; 

	function DeltaBalances() public {
        admin = 0xf6E914D07d12636759868a61E52973d17ED7111B;                                                 
	}

	                                        
	function() public payable {
		revert();
	}
	
	                                       
    modifier isAdmin() {
        require(msg.sender == admin);
	     _;
    }
    
	                           
	function destruct() public isAdmin {
		selfdestruct(admin);
	}

	                                               
	function withdraw() public isAdmin {
    	admin.transfer(this.balance);
	}

	                                                       
	function withdrawToken(address token, uint amount) public isAdmin {
    	require(token != address(0x0));                       
    	require(Token(token).transfer(msg.sender, amount));
	}
  
	                                                                  
                          
                                    
                                                             
        
                                                    
	function deltaBalances(address exchange, address user,  address[] tokens) public view returns (uint[]) {
		Exchange ex = Exchange(exchange);
	    uint[] memory balances = new uint[](tokens.length);
	    
		for(uint i = 0; i< tokens.length; i++){
			balances[i] = ex.balanceOf(tokens[i], user);
		}	
		return balances;
	}
	
	                                                                  
                          
                                    
                                                           
        
                                                 
                                                                                                
	function multiDeltaBalances(address[] exchanges, address user,  address[] tokens) public view returns (uint[]) {
	    uint[] memory balances = new uint[](tokens.length * exchanges.length);
	    
	    for(uint i = 0; i < exchanges.length; i++){
			Exchange ex = Exchange(exchanges[i]);
			
    		for(uint j = 0; j< tokens.length; j++){
    		    
    			balances[(j * exchanges.length) + i] = ex.balanceOf(tokens[j], user);
    		}
	    }
		return balances;
	}
  
                                                            
                            
                                                 
                                           
       
                                                                                 
   function tokenBalance(address user, address token) public view returns (uint) {
                                                
        uint256 tokenCode;
        assembly { tokenCode := extcodesize(token) }                      
        if(tokenCode > 0)
        {
            Token tok = Token(token);
                                           
            if(tok.call(bytes4(keccak256("balanceOf(address)")), user)) {
                return tok.balanceOf(user);
            } else {
                  return 0;                                                    
            }
        } else {
            return 0;                                             
        }
   }
  
                                                               
                                                                             
                          
                                                     
        
                                                    
	function walletBalances(address user,  address[] tokens) public view returns (uint[]) {
	    require(tokens.length > 0);
		uint[] memory balances = new uint[](tokens.length);
		
		for(uint i = 0; i< tokens.length; i++){
			if( tokens[i] != address(0x0) ) {                                    
			    balances[i] = tokenBalance(user, tokens[i]);
			}
			else {
			   balances[i] = user.balance;                
			}
		}	
		return balances;
	}
	
	                                                                                                              
                          
                                                     
        
                                                                  
                                                                 
                                        
	function allBalances(address exchange, address user,  address[] tokens) public view returns (uint[]) {
		Exchange ex = Exchange(exchange);
		uint[] memory balances = new uint[](tokens.length * 2);
		
		for(uint i = 0; i< tokens.length; i++){
		    uint j = i * 2;
			balances[j] = ex.balanceOf(tokens[i], user);
			if( tokens[i] != address(0x0) ) {                                    
			    balances[j + 1] = tokenBalance(user, tokens[i]);
			} else {
			   balances[j + 1] = user.balance;                
			}
		}
		return balances; 
	}
}