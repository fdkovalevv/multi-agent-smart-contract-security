contract PreSentEther{
    address public owner;
    uint256 public money;
    constructor() public{
        owner = msg.sender;
        money = 0;
    }
    
                                                         
                                                     
                                                         
    function depositOnce() external payable{
                                                                                                                                                                                                                                                      
        require(address(this).balance == 0);
        money += msg.value;
    }
    
    function withdraw() external{
        require(msg.sender == owner);
        msg.sender.transfer(money);
    }
}