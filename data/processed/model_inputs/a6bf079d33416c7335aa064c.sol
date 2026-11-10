contract NoWrongName{
    uint256 public constant BET_PRICE = 0.1 ether;                                                       
    address[] public users;
    event Bet(address indexed _user);                                      
    
                                      
    function bet() external payable{
        require(msg.value == BET_PRICE);
        users.push(msg.sender);
        emit Bet(msg.sender);
    }
}