contract complexFallback{
    address[] public payer;
    uint256[] public money;
    address public owner;
    
    constructor() public{
        owner = msg.sender;
    }
    
    function addNewPayer(address _payer) external{
        require(msg.sender == owner);
        payer.push(_payer);
        money.push(0);
    }
    
    function getOwnerMoney() external{
        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
    }
    
                                        
      
                                                            
                                                              
                  
      
                                                                                                                                                                                                                                                                                                                                                                                                                                                               
    fallback() external payable{
        require(msg.value > 0);
        for(uint256 i = 0; i < payer.length; i++){
            if(msg.sender == payer[i])
                money[i] += msg.value;
        }
    }
}