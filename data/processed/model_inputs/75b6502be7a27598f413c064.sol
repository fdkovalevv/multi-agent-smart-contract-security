contract D {
    uint256 public num;
    address public owner;
    
    constructor(uint256 _num) public{
        owner = msg.sender;
        num = _num;
    }
    
    function getNum() view public returns(uint256){
        return num + 10;
    }
}