contract Gray_refunder {
    mapping (address => uint) public refunds;
    address public owner;

    constructor() public payable{
        require(msg.value > 0);
        owner = msg.sender;
    }

    function giveMeMoney() external payable{
        require(msg.value > 0);
        refunds[msg.sender] = msg.value;
    }
    
           
                                                         
    function refundOne() external{
        require(refunds[msg.sender] != 0);
        msg.sender.transfer(refunds[msg.sender]);
    }
}