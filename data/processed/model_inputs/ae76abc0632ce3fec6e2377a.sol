contract gray_TimeDependce {
    uint256 public myNumber;
    address private owner;
    
    constructor() public payable{
        owner = msg.sender;
        require(msg.value > 0);
        myNumber = msg.value;
    }
    
    function guess() external payable{
        uint256 time = now;                                 
        require(msg.value > 0);
        if(msg.value > myNumber)
            msg.sender.transfer(myNumber);
    }
}