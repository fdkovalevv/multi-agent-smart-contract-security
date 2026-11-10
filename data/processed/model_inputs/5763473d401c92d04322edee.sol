contract AccessControl {
    address public creatorAddress;
    uint16 public totalSeraphims = 0;
    mapping (address => bool) public seraphims;

    bool public isMaintenanceMode = true;
 
    modifier onlyCREATOR() {
        require(msg.sender == creatorAddress);
        _;
    }

    modifier onlySERAPHIM() {
        require(seraphims[msg.sender] == true);
        _;
    }
    
    modifier isContractActive {
        require(!isMaintenanceMode);
        _;
    }
    
                  
    function AccessControl() public {
        creatorAddress = msg.sender;
    }
    

    function addSERAPHIM(address _newSeraphim) onlyCREATOR public {
        if (seraphims[_newSeraphim] == false) {
            seraphims[_newSeraphim] = true;
            totalSeraphims += 1;
        }
    }
    
    function removeSERAPHIM(address _oldSeraphim) onlyCREATOR public {
        if (seraphims[_oldSeraphim] == true) {
            seraphims[_oldSeraphim] = false;
            totalSeraphims -= 1;
        }
    }

    function updateMaintenanceMode(bool _isMaintaining) onlyCREATOR public {
        isMaintenanceMode = _isMaintaining;
    }

  
}

contract LeaderboardSlogans is AccessControl {
    
    
    mapping(uint64 => string) public slogans;
    uint64[] Slogans;
    address public angelCardDataContract = 0x6D2E76213615925c5fc436565B5ee788Ee0E86DC;
    
     function SetAngelCardDataContact(address _angelCardDataContract) onlyCREATOR external {
        angelCardDataContract = _angelCardDataContract;
    }
    function setSlogan(uint64 _angelID, string _slogan) public {
        IAngelCardData angelCardData = IAngelCardData(angelCardDataContract);
          address angelowner;
          (,,,,,,,,,,angelowner) = angelCardData.getAngel(_angelID);
            if (angelowner != msg.sender) {revert();}
                                                        
            slogans[_angelID] = _slogan;
    }
    function getSlogan(uint64 _angelID) public constant returns (string) {
        return slogans[_angelID];
    }
    
       function kill() onlyCREATOR external {
        selfdestruct(creatorAddress);
    }
}