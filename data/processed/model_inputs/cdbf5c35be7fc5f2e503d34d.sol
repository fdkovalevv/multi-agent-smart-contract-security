contract IntegerOverflowMinimal {
    uint public count = 1;

    function run(uint256 input) public {
                                    
        count -= input;
    }
}