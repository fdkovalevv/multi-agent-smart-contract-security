contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract StableBalancer is owned {
 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Tx(address _from,address _to, uint256 _value,string _txt);
    
    mapping (address => uint256) balancesHaben;
    mapping (address => uint256) balancesSoll;
    
    function transfer(address _to, uint256 _value) returns (bool success) { return false; throw;}
    
    function balanceHaben(address _owner) constant returns (uint256 balance) {
        return balancesHaben[_owner];
    }
    
    function balanceSoll(address _owner) constant returns (uint256 balance) {
        return balancesSoll[_owner];
    }
    
    function addTx(address _from,address _to, uint256 _value,string _txt) onlyOwner {
        balancesSoll[_from]+=_value;
        balancesHaben[_to]+=_value;
        Tx(_from,_to,_value,_txt);
    }
    
}