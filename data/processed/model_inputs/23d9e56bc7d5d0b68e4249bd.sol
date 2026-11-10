contract UnicornMilk {
                                       
    string public standard = 'Token 0.1';
    string public name = "Unicorn Milk";
    string public symbol = "liters";
    uint8 public decimals = 9;             
    uint256 public totalSupply;
    address[] public minters;
    address public owner;

                                                 
    mapping (address => uint256) public balance;
    mapping (address => mapping (address => uint256)) public allowance;

                                                                                  
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    modifier onlyOwner() {if ( msg.sender != owner ) throw; _;}
    modifier onlyMinters() {if ( !addressInArray(msg.sender) ) throw; _;}

    function UnicornMilk() {
      owner = msg.sender;
    }

                    
    function transfer(address _to, uint256 _value) {
        if (balance[msg.sender] < _value) throw;                                            
        if (balance[_to] + _value < balance[_to]) throw;                       
        if (this == _to){throw;}
        balance[msg.sender] -= _value;                                                
        balance[_to] += _value;                                                            
        Transfer(msg.sender, _to, _value);                                                                           
    }


                                                                    
    function approve(address _spender, uint256 _value)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

                                              
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balance[_from] < _value) throw;                                                  
        if (balance[_to] + _value < balance[_to]) throw;                        
        if (_value > allowance[_from][msg.sender]) throw;                     
        if (this == _to){throw;}
        balance[_from] -= _value;                                                     
        balance[_to] += _value;                                                            
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }



                                                               

       

                                                                        
                                 
           

        function drink(address _from, uint256 _value                                           ) returns (bool success){
                                               
          if (balance[_from] < _value) throw;                                                  
                                                                                                             
          balance[_from] -= _value;                                                     
          Transfer(_from, 0x0000000000000000000000000000000000000000, _value);
          return true;
        }

                        
        function mint(address _to, uint256 _value) onlyMinters {

            if (balance[_to] + _value < balance[_to]) throw;                       
            if (this == _to){throw;}
            balance[_to] += _value;                                                            
          Transfer(this, _to, _value);                                                                                   
        }

        function addMinter(address addr) returns (bool success) {
          if(!addressInArray(addr)){
            minters.push(addr);
            return true;
          }
          return false;
        }

        function removeMinter(address addr) returns (bool success) {
          for(uint i=0; i<minters.length;i++){
            if(minters[i]==addr){
              delete minters[i];
              return true;
            }
          }
          return false;
        }


        function addressInArray(address inAddress) private returns (bool inArray){
          for(uint i=0; i<minters.length;i++){
            if(minters[i]==inAddress){
              return true;
            }
          }
          return false;
        }


        function kill() onlyOwner {
          suicide(owner);
        }

                                                                                    
    function () {
        throw;                                            
    }
}