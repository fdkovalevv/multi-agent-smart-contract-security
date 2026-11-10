contract AccessoryWrapper721 {
          
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event MarketplaceTransfer(address indexed _from, address indexed _to, uint256 _tokenId, address _marketplace);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);


         
    address public creatorAddress;
    uint16 public totalMarketplaces = 0;
    mapping (address => bool) public marketplaces;
    address public accessoryDataContract = 0x466c44812835f57b736ef9F63582b8a6693A14D0;
    
        struct Accessory {
        uint32 accessoryId;
        uint8 accessorySeriesId;
        address owner;
        bool ownerLock;
    }

                    
    function AcceessoryWrapper721() public {
        creatorAddress = msg.sender;
    }
    

    modifier onlyCREATOR() {
        require(msg.sender == creatorAddress);
        _;
    }

 function addMARKETPLACE(address _newMarketplace) onlyCREATOR public {
        if (marketplaces[_newMarketplace] == false) {
           marketplaces[_newMarketplace] = true;
           totalMarketplaces += 1;
        }
    }
    
    function SetAccessoryDataContact(address _accessoryDataContract) onlyCREATOR external {
       accessoryDataContract = _accessoryDataContract;
    }

  function balanceOf(address _owner) public view returns (uint256 _balance) {
           IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
           return accessoryData.getOwnerAccessoryCount(_owner);
  }
  
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
            IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
            address owner;
            (,,owner) = accessoryData.getAccessory(_tokenId);
            return owner;
  }
  
  function getTokenByIndex (address _owner, uint index) constant public returns (uint64) {
                                                                                            
        IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
        return uint64(accessoryData.getAccessoryByIndex(_owner, index));
        
  }
	
	function getAccessory(uint _accessoryId) constant public returns(uint accessoryID, uint8 AccessorySeriesID, address owner) {
       
        IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
        (accessoryID, AccessorySeriesID, owner) = accessoryData.getAccessory(_accessoryId);
       
    }
    function getTokenLockStatus(uint64 _tokenId) constant public returns (bool) {
       IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
       accessoryData.getAccessoryLockStatus(_tokenId);
       
    }

 
  function transfer(address _to, uint256 _tokenId) public {
      
       IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
       address owner;
        (,, owner) = accessoryData.getAccessory(_tokenId);
      
       if ((marketplaces[msg.sender] == true)  || (owner == msg.sender))
       {
         accessoryData.transferAccessory(owner,_to, uint64 (_tokenId)) ;
         Transfer(owner, _to, _tokenId);
         MarketplaceTransfer(owner,  _to, _tokenId, msg.sender);
           
       }
      else {revert();}
  }
  function approve(address _to, uint256 _tokenId) public
  {
                                                                                                                
      revert();
      
  }
  function takeOwnership(uint256 _tokenId) public
  { 
                                                                  
     revert();
  }
  
    }