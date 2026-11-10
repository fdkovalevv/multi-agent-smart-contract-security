contract NobadTxorigin{
    address public owner;
    
    constructor() public payable{
        owner = msg.sender;
        require(msg.value > 0);
    }
    
      
                                                      
                                                       
                                                  
                                     
      
    function withdraw() external{
                                                                                                                                                                                                                                                          
        require(tx.origin == owner);
        msg.sender.transfer(address(this).balance);
    }
}