contract gray_signednessError{
    mapping(address => bool) public transferred;
    address public owner;
    
    constructor() public payable{
        owner = msg.sender;
        require(msg.value > 0 && msg.value % 1 ether == 0);
    }
    
    function withdrawOnce (int amount) public {
                                                           
        require(amount >= 0);
        if ( amount > 1 ether || transferred [msg.sender]) {
            revert() ;
        }
        msg.sender.transfer(uint(amount));
        transferred [msg.sender] = true ;
    }
}