contract HardCodeAddress {
    uint256 private rate;
    uint256 private cap;
    address public owner;
    
                                                  
    constructor() public  {
                                                                                                                     
        owner = 0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed;
        rate = 0;
        cap = 0;
    }

    function setRate(uint256 _rate) external {
        require(owner == msg.sender);
        rate = _rate;
    }

    function setCap(uint256 _cap) external {
        require (msg.sender == owner);
        cap = _cap;
    }
}