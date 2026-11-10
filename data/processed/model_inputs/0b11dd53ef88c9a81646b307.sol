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

contract ABTokenTransfer is AccessControl {
                                                                     
  
    address public angelCardDataContract = 0x6D2E76213615925c5fc436565B5ee788Ee0E86DC;
    address public petCardDataContract = 0xB340686da996b8B3d486b4D27E38E38500A9E926;
    address public accessoryDataContract = 0x466c44812835f57b736ef9F63582b8a6693A14D0;
    address public ABTokenDataContract = 0xDC32FF5aaDA11b5cE3CAf2D00459cfDA05293F96;
 

    
                        


    struct Angel {
        uint64 angelId;
        uint8 angelCardSeriesId;
        address owner;
        uint16 battlePower;
        uint8 aura;
        uint16 experience;
        uint price;
        uint64 createdTime;
        uint64 lastBattleTime;
        uint64 lastVsBattleTime;
        uint16 lastBattleResult;
    }

    struct Pet {
        uint petId;
        uint8 petCardSeriesId;
        address owner;
        string name;
        uint8 luck;
        uint16 auraRed;
        uint16 auraYellow;
        uint16 auraBlue;
        uint64 lastTrainingTime;
        uint64 lastBreedingTime;
        uint price; 
        uint64 liveTime;
    }
    
     struct Accessory {
        uint16 accessoryId;
        uint8 accessorySeriesId;
        address owner;
    }


                      
    function DataContacts(address _angelCardDataContract, address _petCardDataContract, address _accessoryDataContract, address _ABTokenDataContract) onlyCREATOR external {
        angelCardDataContract = _angelCardDataContract;
        petCardDataContract = _petCardDataContract;
        accessoryDataContract = _accessoryDataContract;
        ABTokenDataContract = _ABTokenDataContract;
     
      
    }
   
  function claimPet(uint64 petID) public {
       IPetCardData petCardData = IPetCardData(petCardDataContract);
       IABToken ABTokenData = IABToken(ABTokenDataContract);
       if ((petID <= 0) || (petID > petCardData.getTotalPets())) {revert();}
       Pet memory pet;
       (pet.petId,pet.petCardSeriesId,,pet.luck,pet.auraRed,pet.auraBlue,pet.auraYellow,,,pet.owner) = petCardData.getPet(petID);
       if ((msg.sender != pet.owner) && (seraphims[msg.sender] == false)) {revert();}
                                                      
       petCardData.transferPet(pet.owner,0x0,petID);
                                     
       ABTokenData.mintABToken(pet.owner,pet.petCardSeriesId + 23, pet.luck, pet.auraRed, pet.auraYellow, pet.auraBlue, pet.name,0, uint16(pet.petId));
  }
       
    function claimAccessory(uint64 accessoryID) public {
       IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
       IABToken ABTokenData = IABToken(ABTokenDataContract);
       if ((accessoryID <= 0) || (accessoryID > accessoryData.getTotalAccessories())) {revert();}
      Accessory memory accessory;
       (,accessory.accessorySeriesId,accessory.owner) = accessoryData.getAccessory(accessoryID);
       
                                                            
                                                                          
       accessoryData.transferAccessory(accessory.owner,0x0,accessoryID);
                                     
       ABTokenData.mintABToken(accessory.owner,accessory.accessorySeriesId + 42, 0, 0, 0, 0, "0",0, uint16(accessoryID));
  }
       
       function claimAngel(uint64 angelID) public {
       IAngelCardData angelCardData = IAngelCardData(angelCardDataContract);
       IABToken ABTokenData = IABToken(ABTokenDataContract);
       if ((angelID <= 0) || (angelID > angelCardData.getTotalAngels())) {revert();}
       Angel memory angel;
       (angel.angelId, angel.angelCardSeriesId, angel.battlePower, angel.aura, angel.experience,,,,,, angel.owner) = angelCardData.getAngel(angelID);
       
                                                        
                                               
       angelCardData.transferAngel(angel.owner,0x0,angel.angelId);
                                    
       uint16 auraRed = 0;
       uint16 auraYellow = 0;
       uint16 auraBlue = 0;
       if (angel.aura == 1)  {auraBlue = 1;}            
       if (angel.aura == 2)  {auraYellow = 1;}               
       if (angel.aura == 3)  {auraBlue = 1; auraRed = 1;}              
       if (angel.aura == 4)  {auraYellow = 1; auraRed = 1;}                
       if (angel.aura == 5)  {auraRed = 1;}           
       if (angel.aura == 6)  {auraBlue = 1; auraYellow =1;}             
       ABTokenData.mintABToken(angel.owner,angel.angelCardSeriesId, angel.battlePower, auraRed, auraYellow, auraBlue,"0",angel.experience, uint16(angel.angelId));
  }
       
       
        
     
      function kill() onlyCREATOR external {
        selfdestruct(creatorAddress);
    }
}