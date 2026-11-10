contract ERC20 {
    function totalSupply() constant returns (uint256 totalSupply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract MainstreetToken is ERC20 {
    
    mapping (address => uint) ownerMIT;
    mapping (address => mapping (address => uint)) allowed;
    uint public totalMIT;
    uint public start;
    
    address public mainstreetCrowdfund;

    address public intellisys;
    
    bool public testing;

    modifier fromCrowdfund() {
        if (msg.sender != mainstreetCrowdfund) {
            throw;
        }
        _;
    }
    
    modifier isActive() {
        if (block.timestamp < start) {
            throw;
        }
        _;
    }

    modifier isNotActive() {
        if (!testing && block.timestamp >= start) {
            throw;
        }
        _;
    }

    modifier recipientIsValid(address recipient) {
        if (recipient == 0 || recipient == address(this)) {
            throw;
        }
        _;
    }

    modifier senderHasSufficient(uint MIT) {
        if (ownerMIT[msg.sender] < MIT) {
            throw;
        }
        _;
    }

    modifier transferApproved(address from, uint MIT) {
        if (allowed[from][msg.sender] < MIT || ownerMIT[from] < MIT) {
            throw;
        }
        _;
    }

    modifier allowanceIsZero(address spender, uint value) {
                                                                               
                                                                          
                                                                   
                                                                            
        if ((value != 0) && (allowed[msg.sender][spender] != 0)) {
            throw;
        }
        _;
    }

       
                                                                              
                                                  
                                      
       
    event TokensAdded(address indexed recipient, uint MIT);

       
                        
                                                                 
                                                                
                                                             
       
    function MainstreetToken(address _mainstreetCrowdfund, address _intellisys, uint _start, bool _testing) {
        mainstreetCrowdfund = _mainstreetCrowdfund;
        intellisys = _intellisys;
        start = _start;
        testing = _testing;
    }
    
       
                                                                    
                                                 
                                        
       
    function addTokens(address recipient, uint MIT) external isNotActive fromCrowdfund {
        ownerMIT[recipient] += MIT;
        uint intellisysMIT = MIT / 10;
        ownerMIT[intellisys] += intellisysMIT;
        totalMIT += MIT + intellisysMIT;
        TokensAdded(recipient, MIT);
        TokensAdded(intellisys, intellisysMIT);
    }

       
                                          
       
    function totalSupply() constant returns (uint256 totalSupply) {
        totalSupply = totalMIT;
    }

       
                                        
       
    function balanceOf(address _owner) constant returns (uint256 balance) {
        balance = ownerMIT[_owner];
    }

       
                                       
       
    function transfer(address _to, uint256 _value) isActive recipientIsValid(_to) senderHasSufficient(_value) returns (bool success) {
        ownerMIT[msg.sender] -= _value;
        ownerMIT[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

       
                                           
       
    function transferFrom(address _from, address _to, uint256 _value) isActive recipientIsValid(_to) transferApproved(_from, _value) returns (bool success) {
        ownerMIT[_to] += _value;
        ownerMIT[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

       
                                      
       
    function approve(address _spender, uint256 _value) isActive allowanceIsZero(_spender, _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

       
                                        
       
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        remaining = allowed[_owner][_spender];
    }

}