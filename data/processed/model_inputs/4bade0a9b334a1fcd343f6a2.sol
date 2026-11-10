contract NoWaste4{
    uint256 public constant ticket = 1 ether;
    uint256 public constant earnings = 0.1 ether;
    uint256 public number = 0;
    address[] public participants;
    
    constructor() public payable{
                          
        require(msg.value == ticket);
        participants.push(msg.sender);
    }
    
    
    function join() external payable{
        require(msg.value == ticket);
                            
        uint256 money = participants.length * earnings;
        msg.sender.transfer(money);
        number += 1;
    }

    function getNumber() view external returns(uint256){
        return number;
    }
}