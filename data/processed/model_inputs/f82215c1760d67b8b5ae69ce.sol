contract MyToken {
                                       
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

                                                 
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

                                                                                  
    event Transfer(address indexed from, address indexed to, uint256 value);

                                                                                        
    function MyToken() {
        totalSupply = 10000;
        balanceOf[msg.sender] = totalSupply;                                                    
        name = "megabank";                                                                       
        symbol = "xUSD";                                                                     
        decimals = 0;                                                                      
    }

                     
    
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;                                            
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;                       
        balanceOf[msg.sender] -= _value;                                                
        balanceOf[_to] += _value;                                                            
                                                                                                                       
    }


                                                                                    
    function () {
        throw;                                            
    }
}