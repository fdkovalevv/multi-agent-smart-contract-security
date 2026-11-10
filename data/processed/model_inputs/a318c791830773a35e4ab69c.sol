contract TypoSafeMath {

    using SafeMath for uint256;
    uint256 public numberOne = 1;
    bool public win = false;

    function addOne() public {
        numberOne =+ 1;
    }

    function addOneCorrect() public {
        numberOne += 1;
    }

    function addOneSafeMath() public  {
        numberOne = numberOne.add(1);
    }

    function iWin() public {
        if(!win && numberOne>3) {
            win = true;
        }
    }
}