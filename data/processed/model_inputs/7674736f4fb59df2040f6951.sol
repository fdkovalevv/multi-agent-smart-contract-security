contract myBonus{
    address public owner;
    address payable[] public myPartners;
    
    constructor() public{
        owner = msg.sender;
    }
    
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    function depositOnce() external payable onlyOwner{
        require(msg.value == 1 ether);
    }
    
    function addNewPartner(address payable _friend) external onlyOwner{
        myPartners.push(_friend);
    }
    
                                                                       
                                              
                                                                        
    function deletePartner(address _badGuy) external onlyOwner{
        uint256 _length = myPartners.length;
        for(uint256 i = 0; i < _length; i++){
            if(myPartners[i] == _badGuy)
                                                                                                                                                                                                                                                                                                                           
                delete myPartners[i];
        }
    }
    
      
                                                                            
          
                                                                             
                                                                      
      
    function sendEther() external onlyOwner{
        uint256 _length = myPartners.length;
        for(uint256 i = 0; i < _length; i++){
            myPartners[i].transfer(1 ether);
        } 
    }
}