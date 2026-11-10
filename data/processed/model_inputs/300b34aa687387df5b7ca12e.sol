contract RaisingToken {
       
                                             
       
    uint256 public totalSupply;

       
                                                                               
                            
       
    mapping (address => uint256) public balanceOf;

       
                                                                           
                                                                         
       
    mapping (address => mapping (address => uint256)) allowance;

       
                                                                         
                                         
       
    function RaisingToken () public payable {
                                            
        require (msg.value > 0);

                             
        totalSupply = 1;

                                            
        balanceOf [msg.sender] = 1;

                             
        Transfer (address (0), msg.sender, 1);
    }

       
                                 
       
    function buy() public payable {
                                                                            
        uint256 count = msg.value * totalSupply / this.balance;

                                                                
        require (count > 0);

                                   
        totalSupply += count;

                                              
        balanceOf [msg.sender] += count;

                             
        Transfer (address (0), msg.sender, count);
    }

       
                                            
      
                                             
                                                                     
       
    function sell(uint256 _value) public returns (bool) {
                          
                                                     
                                                                          
                                                      
        if (_value > 0 &&
            _value < totalSupply &&
            _value <= balanceOf [msg.sender]) {
                                                             
            uint256 toSend = _value * this.balance / totalSupply;

                                                       
            if (!msg.sender.send (toSend))
                return false;                      

                                          
            balanceOf [msg.sender] -= _value;

                                
            totalSupply -= _value;

                                
            Transfer (msg.sender, address (0), _value);

                             
            return true;
        } else return false;                  
    }

       
                      
       
                         
       
    function name() public pure returns (string) {
        return "RaisingToken";
    }

       
                        
       
                           
       
    function symbol() public pure returns (string) {
        return "RAT";
    }

       
                          
       
                             
       
    function decimals() public pure returns (uint8) {
        return 0;
    }

       
                                                                                
                                                          
      
                                                        
                                                                          
                                                                     
       
    function transfer(address _to, uint256 _value) public returns (bool) {
                          
                                                            
                                              
        if (_value > 1 && _value >= balanceOf [msg.sender]) {
                                              
            balanceOf [msg.sender] -= _value;

                                              
            _value -= 1;

                                       
            balanceOf [_to] += _value;

                              
            totalSupply -= 1;

                                 
            Transfer (msg.sender, _to, _value);

                                
            Transfer (msg.sender, address (0), 1);

                             
            return true;
        } else return false;                  
    }

       
                                                                                
                                                                              
                                                                              
      
                                  
                                     
                                                                             
                   
                                                                     
       
    function transferFrom(address _from, address _to, uint256 _value)
        public returns (bool) {
                          
                                                            
                                                                 
                                                           
        if (_value > 1 &&
            _value >= allowance [_from][msg.sender] &&
            _value >= balanceOf [_from]) {
                                                                            
                                               
            allowance [_from][msg.sender] -= _value;

                                                           
            balanceOf [_from] -= _value;

                                              
            _value -= 1;

                                                              
            balanceOf [_to] += _value;
    
                              
            totalSupply -= 1;
    
                                 
            Transfer (_from, _to, _value);

                                
            Transfer (_from, address (0), 1);
    
                             
            return true;
        } else return false;                  
    }

       
                                                                               
                                  
      
                                                                 
                                                          
                                                                          
       
    function approve(address _spender, uint256 _value) public returns (bool) {
                                 
        allowance [msg.sender][_spender] = _value;

                                
        Approval (msg.sender, _spender, _value);
    }

       
                                                               
      
                                                                               
                     
                                                                           
                    
                                                                     
       
    event Transfer(
        address indexed _from, address indexed _to, uint256 _value);

       
                                               
      
                                                                              
                                                          
                                                               
       
    event Approval(
        address indexed _owner, address indexed _spender, uint256 _value);
}