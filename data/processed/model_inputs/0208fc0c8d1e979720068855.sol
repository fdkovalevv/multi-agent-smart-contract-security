contract ElectroPuppy {

    uint256 public carbonCredit = 0;

                                                                                  
    function addCarbonCredit(uint256 value) public {
        carbonCredit += value;
    }

}