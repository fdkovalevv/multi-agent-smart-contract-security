contract gray_Constant{
    uint counter;
    constructor(uint256 _counter) public{
        counter = _counter;
    }
    
    function get() external view returns(uint){
       return counter;
    }

    function getPlusTwo() external constant returns(uint){
        return counter;
    }
}