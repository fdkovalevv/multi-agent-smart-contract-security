contract prodigal{
    address public owner;
    constructor() public payable{
        owner = msg.sender;
        require(msg.value > 0);
    }
    
    modifier onlyOnwer{
        require(msg.sender == owner);
        _;
    }
    
      
                                                                                                        
      
    function withdraw() external{
                                                                                                                                                                                                                                           
        msg.sender.transfer(address(this).balance);
    }
}