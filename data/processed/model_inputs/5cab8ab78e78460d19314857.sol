contract gray_badTxorigin{
    uint256 public visitTimes;
    
    constructor() public{
        visitTimes = 0;
    }
    
                                                             
    function visitContract() external{
        require(tx.origin == msg.sender);
        visitTimes += 1;
    }
    
    function getTimes() view external returns(uint256){
        return visitTimes;
    }
}