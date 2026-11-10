contract TokenInterface {
      
              
       
    event Mint(address indexed _owner);
    event Destroy(address _owner);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event MinterAdded(address who);
    event MinterRemoved(address who);

      
               
       
                               
                                             
    function mint(address _owner) returns (bool success);

                            
                                                          
    function destroy(address _owner) returns (bool success);

                             
                                                                
    function addMinter(address who) returns (bool);

                            
                                                                       
    function removeMinter(address who) returns (bool);

      
                                        
       

                                        
    function totalSupply() constant returns (uint supply);

                                                                      
                                              
                                                          
    function transfer(address _to, uint256 _value) returns (bool success);

                                                                                                        
                                            
                                              
                                                          
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

                                                                                   
                                            
                                                            
    function approve(address _spender, uint256 _value) returns (bool success);

      
                             
       
                                                                                
                                             
    function balanceOf(address _owner) constant returns (uint256 balance);

                                                                                     
                                             
                                                 
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

      
                                 
       
                                                      
                                       
    function isTokenOwner(address _owner) constant returns (bool);
}

contract IndividualityTokenInterface {
      
                             
       

                                                                                
                                             
    function balanceOf(address _owner) constant returns (uint256 balance);

                                                                                     
                                             
                                                 
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

      
                               
       

                                                                      
                                              
                                                          
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transfer(address _to) public returns (bool success);

                                                                                                        
                                            
                                              
                                                          
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to) public returns (bool success);

                                                                                   
                                            
                                                            
    function approve(address _spender, uint256 _value) public returns (bool success);
    function approve(address _spender) public returns (bool success);

      
                                 
       

                                                      
                                       
    function isTokenOwner(address _owner) constant returns (bool);
}

contract IndividualityToken is TokenInterface, IndividualityTokenInterface {
    function IndividualityToken() {
        minters[msg.sender] = true;
        MinterAdded(msg.sender);
    }

    modifier minterOnly {
        if(!minters[msg.sender]) throw;
        _;
    }

                         
    mapping (address => bool) minters;
    
                       
    mapping (address => uint) balances;

                                  
    mapping (address => mapping (address => uint)) approvals;

    uint numTokens;

                               
                                          
    function mint(address _to) minterOnly returns (bool success) {
                                                                   
        if (balances[_to] != 0x0) return false;

        balances[_to] = 1;

                                         
        Mint(_to);
        Transfer(0x0, _to, 1);
        TokenEventLib._Transfer(0x0, _to);

                               
        numTokens += 1;

        return true;
    }
    
                                
    function mint(address[] _to) minterOnly returns (bool success) {
        for(uint i = 0; i < _to.length; i++) {
            if(balances[_to[i]] != 0x0) return false;
            balances[_to[i]] = 1;
            Mint(_to[i]);
            Transfer(0x0, _to[i], 1);
            TokenEventLib._Transfer(0x0, _to[i]);
        }
        numTokens += _to.length;
        return true;
    }

                            
                                                           
    function destroy(address _owner) minterOnly returns (bool success) {
        if(balances[_owner] != 1) throw;
        
        balances[_owner] = 0;
        numTokens -= 1;
        Destroy(_owner);
        return true;
    }

                             
                                                                
    function addMinter(address who) minterOnly returns (bool) {
        minters[who] = true;
        MinterAdded(who);
    }

                            
                                                                       
    function removeMinter(address who) minterOnly returns (bool) {
        minters[who] = false;
        MinterRemoved(who);
    }

                                        
    function totalSupply() constant returns (uint supply) {
        return numTokens;
    }

                                                                                
                                             
    function balanceOf(address _owner) constant returns (uint256 balance) {
        if (_owner == 0x0) {
            return 0;
        } else {
            return balances[_owner];
        }
    }

                                                                                     
                                             
                                                 
    function allowance(address _owner,
                       address _spender) constant returns (uint256 remaining) {
        return approvals[_owner][_spender];
    }

                                                                      
                                              
                                                          
    function transfer(address _to,
                      uint256 _value) public returns (bool success) {
        if (_value != 1) {
                                                             
            return false;
        } else if (_to == 0x0) {
                                                   
            return false;
        } else if (balances[msg.sender] == 0x0) {
                                              
            return false;
        } else if (balances[_to] != 0x0) {
                                                                       
            return false;
        }

        balances[msg.sender] = 0;
        balances[_to] = 1;
        Transfer(msg.sender, _to, 1);
        TokenEventLib._Transfer(msg.sender, _to);

        return true;
    }

                                                                      
                                              
    function transfer(address _to) public returns (bool success) {
        return transfer(_to, 1);
    }

                                                                                                        
                                            
                                              
                                                          
    function transferFrom(address _from,
                          address _to,
                          uint256 _value) public returns (bool success) {
        if (_value != 1) {
                                                           
            return false;
        } else if (_to == 0x0) {
                                                  
            return false;
        } else if (balances[_from] == 0x0) {
                                                            
            return false;
        } else if (balances[_to] != 0x0) {
                                                         
            return false;
        } else if (approvals[_from][msg.sender] == 0) {
                                                                            
            return false;
        }

                                
        approvals[_from][msg.sender] = 0x0;

                                            
        balances[_from] = 0;

                                            
        balances[_to] = 1;

                           
        Transfer(_from, _to, 1);
        TokenEventLib._Transfer(_from, _to);

        return true;
    }

                                                                                                        
                                            
                                              
    function transferFrom(address _from, address _to) public returns (bool success) {
        return transferFrom(_from, _to, 1);
    }

                                                                                   
                                            
                                                            
    function approve(address _spender,
                     uint256 _value) public returns (bool success) {
        if (_value != 1) {
                                                    
            return false;
        } else if (_spender == 0x0) {
                                                            
            return false;
        } else if (balances[msg.sender] == 0x0) {
                                                   
            return false;
        }

        approvals[msg.sender][_spender] = 1;

        Approval(msg.sender, _spender, 1);
        TokenEventLib._Approval(msg.sender, _spender);

        return true;
    }

                                                                                   
                                            
    function approve(address _spender) public returns (bool success) {
        return approve(_spender, 1);
    }

      
                                 
       
                                                      
                                       
    function isTokenOwner(address _owner) constant returns (bool) {
        return balances[_owner] != 0;
    }
}