contract NoNestedCall1{
    uint256[] public element;                    
    uint256 public constant addNum = 1;
    address public owner;
    
    constructor() public{
        owner = msg.sender;
    }
    
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    
                                                 
    function appendDate(uint256 _ele) public onlyOwner{
        require(msg.sender == owner);
        element.push(_ele);
    }
    
                                                                                                          
    function addOne() public onlyOwner{
        require(msg.sender == owner);
        uint256 _length = element.length;
        for(uint256 i = 0; i < _length; i++)
            element[i] += 1;
    }
}