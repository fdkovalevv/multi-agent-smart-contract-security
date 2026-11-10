contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract Ferrum is owned{
    
                                    
    bytes32 public name;
    bytes32 public symbol;
    uint8 public decimals = 5;
    uint256 public totalSupply;
    bool public stopped = false;


                                              
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    modifier isOwner {
        assert(owner == msg.sender);
        _;
    }

    modifier isRunning {
        assert (!stopped);
        _;
    }

    modifier validAddress {
        assert(0x0 != msg.sender);
        _;
    }



                                                                               
    event Transfer(address indexed from, address indexed to, uint256 value);

                                                   

       
                          
      
                                                                                     
       

    function Ferrum (
    
    ) public {
        
        totalSupply = 15800000000000;                                                                     
        balanceOf[msg.sender] = 15800000000000;                                                   
        name = "Ferrum";                                                                        
        symbol = "FRM";                                                                           
        
    }
    

       
                                                             
       
    function _transfer(address _from, address _to, uint _value) internal {
                                                              
        require(_to != 0x0);
                                         
        require(balanceOf[_from] >= _value);
                              
        require(balanceOf[_to] + _value > balanceOf[_to]);
                                                   
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
                                   
        balanceOf[_from] -= _value;
                                        
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
                                                                                                    
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
        event Approval(address indexed _owner, address indexed _spender, uint256 _value);

          
                      
      
                                                      
      
                                              
                                       
       

    function transferTEST(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);                                            
        require(balanceOf[_to] + _value >= balanceOf[_to]);                       
        balanceOf[msg.sender] -= _value;                                               
        balanceOf[_to] += _value;                                                           
    }


       
                                         
      
                                                         
      
                                             
                                              
                                       
       
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);                       
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    
       
                                      
      
                                                                             
      
                                                      
                                                  
       
    function approve(address _spender, uint256 _value) isRunning validAddress public returns (bool success) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
}