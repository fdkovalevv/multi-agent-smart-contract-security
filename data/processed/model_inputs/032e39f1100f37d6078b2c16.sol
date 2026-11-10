contract NoSignednessError{
    mapping(address => bool) public transferred;
    address public owner;
    
    constructor() public payable{
        owner = msg.sender;
        require(msg.value > 0 && msg.value % 1 ether == 0);
    }
    
    function withdrawOnce (uint amount) public {
        if ( amount > 1 ether || transferred [msg.sender]) {
            revert() ;
        }
        msg.sender.transfer(uint(amount));
        transferred [msg.sender] = true ;
    }
}