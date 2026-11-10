contract gray_ConstlyLoop{
    uint256[] public element;                    
    uint256 public constant addNum = 1;
    address public owner;
    uint256 public index;
    
    constructor() public{
        owner = msg.sender;
        index = 0;
    }
    
                                               
    function appendDate(uint256 _ele) public{
        require(msg.sender == owner);
        element.push(_ele);
    }
    
      
                                                                       
                                                                        
                                
      
                                              
                                                      
    function addOne(uint256 _length) public{
        require(msg.sender == owner);
        uint256 boundary = index + _length;
        if(boundary > element.length)
            boundary = element.length;
        for(uint256 i = index; i < boundary; i++)
            element[i] += 1;
        if(boundary == element.length)
            index = 0;               
        else
            index += _length;                 
    }
}