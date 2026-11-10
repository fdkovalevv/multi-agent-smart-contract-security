contract gray_truncationError{
    uint256 public myNumber;
    
    constructor(uint256 _myNumber) public{
        myNumber = _myNumber;
    }    
    
    function shortToLong(uint32 _yourNumber) external{
                           
        require(myNumber + uint256(_yourNumber) >= myNumber);
        myNumber += uint256(_yourNumber);
    }
}