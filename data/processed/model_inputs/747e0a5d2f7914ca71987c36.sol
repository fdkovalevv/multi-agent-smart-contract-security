contract BaseAgriChainContract {
    address creator; 
    function BaseSmartContract() public    {   creator = msg.sender;   }
    
    modifier onlyBy(address _account)
    {
        if (msg.sender != _account)
            throw;
        _;
    }
    
    function kill() onlyBy(creator)
    {               suicide(creator);     }
    
     function setCreator(address _creator)  onlyBy(creator)
    {           creator = _creator;     }
  
}