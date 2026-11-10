contract BobAnswer{
    uint256 private answer;                                    
    address public owner;
    
    constructor(uint256 _answer) public{
        owner = msg.sender;
        answer = _answer;
    } 
    
                                                                    
                                      
    function getAnswer() external payable returns(uint256){
                                                                                                                                                                                                                                                                                                                                                                             
        require(address(this).balance % 1 ether == 0); 
        require(msg.value > 0);
        return answer;
    }
    
    function withdraw() external{
        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
    }
}