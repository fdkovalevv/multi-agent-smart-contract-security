contract EdgelessToken {
                                       
    string public standard = 'ERC20';
    string public name = 'Edgeless';
    string public symbol = 'EDG';
    uint8 public decimals = 0; 
    uint256 public totalSupply;
    uint256 public currentInterval = 1;
    uint256 public intervalLength = 30 days;
    uint256 public startTime = 1490112000;                                                        
    address public owner;

                                                 
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    
                                                                                
    mapping(address => mapping(uint256=>uint256)) public locked;

                                                                                  
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Lock(address indexed owner, uint256 interval, uint256 value);
    
                                                                                        
    function EdgelessToken() {
        owner = 0x003230BBE64eccD66f62913679C8966Cf9F41166;
        balanceOf[owner] = 500000000;                                                  
        totalSupply = 500000000;                                                         
    }

                    
    function transfer(address _to, uint256 _value) returns (bool success){
        if (now < startTime) throw;                                         
        if (balanceOf[msg.sender]-locked[msg.sender][getInterval()] < _value) throw;                                    
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;                       
        balanceOf[msg.sender] -= _value;                                                
        balanceOf[_to] += _value;                                                            
        Transfer(msg.sender, _to, _value);                                                                           
        return true;
    }

                                                                    
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

                                                                          
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }        

                                              
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (now < startTime && _from!=owner) throw;                                         
        if (balanceOf[_from]-locked[_from][getInterval()] < _value) throw;                                      
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;                        
        if (_value > allowance[_from][msg.sender]) throw;                     
        balanceOf[_from] -= _value;                                                     
        balanceOf[_to] += _value;                                                            
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
    
                                 
    function lock(address holder, uint256 _value) returns (bool success) {
        if(holder==msg.sender||holder==tx.origin){
            locked[holder][getInterval()]+=_value;
            Lock(holder, currentInterval, _value);
            return true;
        }
    }
    
                                                              
    function getInterval() returns (uint256 interval){
        if (now > currentInterval * intervalLength + startTime) {
            currentInterval = (now - startTime) / intervalLength + 1;
        }
        return currentInterval;
    }

}