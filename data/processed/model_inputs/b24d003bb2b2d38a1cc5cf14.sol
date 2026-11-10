contract NoHardCodeAddress {
    uint256 private rate;
    uint256 private cap;
    address public owner;
    
                                   
    constructor() public  {
        owner = msg.sender;
        rate = 0;
        cap = 0;
    }

    function setRate(uint256 _rate) public  {
        require(owner == msg.sender);
        rate = _rate;
    }

    function setCap(uint256 _cap) public {
        require (msg.sender == owner);
        cap = _cap;
    }
}