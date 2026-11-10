contract Constant{
    uint counter;
    constructor(uint256 _counter) public{
        counter = _counter;
    }
    
    function get() public view returns(uint){
       counter = counter +1;
       return counter;
    }

    function getPlusTwo() external constant returns(uint){
        counter += 2;
        return counter;
    }
}