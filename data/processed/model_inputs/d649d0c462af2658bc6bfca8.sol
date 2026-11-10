contract IntegerOverflowMultiTxOneFuncFeasible {

    uint256 private initialized = 0;
    uint256 public count = 1;

    function run(uint256 input) public {
        if (initialized == 0) {
            initialized = 1;
            return;
        }

        count = sub(count, input);
    }

                   
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);                           
        return a - b;
    }
}