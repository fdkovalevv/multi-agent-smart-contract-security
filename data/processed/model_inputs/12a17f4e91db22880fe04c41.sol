contract MissConstructor{
    address public owner;
    
      
                                                           
                                                           
                                                            
                 
      
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    function missConstructor() public payable{
        owner = msg.sender;
        require(msg.value > 0);
    }
    
    function getMyBalance() external{
        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
    }
}