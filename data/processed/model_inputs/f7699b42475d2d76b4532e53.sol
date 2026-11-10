contract BaseSmartContract {
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

contract SmartFoodProductionContract   is BaseSmartContract    
{
    string  public  Organization;
    string  public  Product ;
    address public  Production;
    
    function setOrganization(string _Organization)  onlyBy(creator)
    {
          Organization = _Organization;
       
    }
    
    function setProduct(string _Product)  onlyBy(creator)
    {
          Product = _Product;
        
    }
    function setProduction(address _Production)  onlyBy(creator)
    {
         Production = _Production;
         
    }
}