contract SimoneContract {
    
    event PaidBy(
        address indexed _from,
        uint _value
    );
    
    function deposit() payable {
        PaidBy(msg.sender, msg.value);
    }
    
    function widthdraw() onlyOwner {
        bool res = owner.send(this.balance);
    }
    
    address public owner;
    
                     
    function SimoneContract () {
        owner= msg.sender;
    }
    
    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }
    function changeOwner(address newOwner) onlyOwner  {
        owner= newOwner;
    }
    
    
}