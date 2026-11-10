contract TypoOneCommand {
    uint numberOne = 1;

    function alwaysOne() public {
        numberOne =+ 1;
    }
}