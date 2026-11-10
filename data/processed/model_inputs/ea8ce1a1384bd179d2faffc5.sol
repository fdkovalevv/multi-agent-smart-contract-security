contract SafeMath {
    function safeMul(uint a, uint b) internal returns(uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal returns(uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns(uint) {
        assert(b <= a);
        return a - b;
    }
    
    function safeAdd(uint a, uint b) internal returns(uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

}

contract ERC20 {
    uint public totalSupply;

    function balanceOf(address who) constant returns(uint);

    function allowance(address owner, address spender) constant returns(uint);

    function transfer(address to, uint value) returns(bool ok);

    function transferFrom(address from, address to, uint value) returns(bool ok);

    function approve(address spender, uint value) returns(bool ok);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Ownable {
    address public owner;

    function Ownable() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) owner = newOwner;
    }

    function kill() {
        if (msg.sender == owner) selfdestruct(owner);
    }

    modifier onlyOwner() {
        if (msg.sender == owner)
        _;
    }
}

contract GXC is ERC20, SafeMath, Ownable {
                                    
    string public name;
    string public symbol;
    uint8 public decimals;                              
    string public version = 'v0.1';
    uint public initialSupply;
    uint public totalSupply;
    bool public locked;
    address public crowdSaleAddress;
    uint multiplier = 10000000000;        
    
    uint256 public totalMigrated;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    

                                   
    modifier onlyUnlocked() {
        if (msg.sender != crowdSaleAddress && locked && msg.sender != owner) revert();
        _;
    }

    modifier onlyAuthorized() {
        if ( msg.sender != crowdSaleAddress && msg.sender != owner) revert();
        _;
    }

                                
    function GXC(address _crowdSaleAddress) {        
        locked = true;                                                     
        initialSupply = 10000000 * multiplier;
        totalSupply = initialSupply;
        name = 'GXC';                                     
        symbol = 'GXC';                                       
        decimals = 10;                                           
        crowdSaleAddress = _crowdSaleAddress;               
        balances[crowdSaleAddress] = totalSupply;       
    }


    function restCrowdSaleAddress(address _newCrowdSaleAddress) onlyAuthorized() {
            crowdSaleAddress = _newCrowdSaleAddress;
    }

    

    function unlock() onlyAuthorized {
        locked = false;
    }

      function lock() onlyAuthorized {
        locked = true;
    }

    function burn( address _member, uint256 _value) onlyAuthorized returns(bool) {
        balances[_member] = safeSub(balances[_member], _value);
        totalSupply = safeSub(totalSupply, _value);
        Transfer(_member, 0x0, _value);
        return true;
    }

    function transfer(address _to, uint _value) onlyUnlocked returns(bool) {
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

                                              
    function transferFrom(address _from, address _to, uint256 _value) onlyUnlocked returns(bool success) {
        if (balances[_from] < _value) revert();                                  
        if (_value > allowed[_from][msg.sender]) revert();                   
        balances[_from] = safeSub(balances[_from], _value);                            
        balances[_to] = safeAdd(balances[_to], _value);                                 
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns(uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) returns(bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) constant returns(uint remaining) {
        return allowed[_owner][_spender];
    }
}