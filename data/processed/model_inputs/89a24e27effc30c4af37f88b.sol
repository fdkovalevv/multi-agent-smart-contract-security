contract IntegerOverflowMinimal {
    uint public count = 1;

    function run(uint256 input) public {
        count = sub(count,input);
    }

                   
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);                           
        return a - b;
    }
}