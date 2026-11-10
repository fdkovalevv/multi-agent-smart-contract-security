contract WrongName{
    uint256 public constant betprice = 0.1 ether;                                                       
    address[] public users;
    event bet(address indexed _user);                                      
    
                                      
    function Bet() external payable{
        require(msg.value == betprice);
        users.push(msg.sender);
        emit bet(msg.sender);
    }
}