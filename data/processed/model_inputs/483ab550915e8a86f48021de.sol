contract NotooManyDigits2{
    uint256 public oncePrice = 1e18;         
    address[] public users;
    address payable owner;
    
    constructor() public{
        owner = msg.sender;
    }
    
    function withdraw() external{
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }
    
    function pay() external payable{
        require(msg.value == oncePrice);                    
        users.push(msg.sender);
    }
}