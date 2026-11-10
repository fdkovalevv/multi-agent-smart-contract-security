contract gray_NestedCall{
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
    
                                                 
    function appendDate(uint256 _ele) external onlyOwner{
        require(msg.sender == owner);
        element.push(_ele);
    }
    
    function addOne() public onlyOwner{
        require(msg.sender == owner);
        for(uint256 i = 0; i < element.length; i++)
            element[i] += 1;
    }
}