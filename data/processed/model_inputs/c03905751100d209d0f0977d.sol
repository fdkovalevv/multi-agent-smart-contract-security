contract LANDStorage {

  mapping (address => uint) latestPing;

  uint256 constant clearLow = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
  uint256 constant clearHigh = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
  uint256 constant factor = 0x100000000000000000000000000000000;

  mapping (address => bool) authorizedDeploy;

}

contract OwnableStorage {

  address public owner;

  function OwnableStorage() internal {
    owner = msg.sender;
  }

}

contract ProxyStorage {

     
                                             
     
  address public currentContract;
  address public proxyOwner;
}

contract AssetRegistryStorage {

  string internal _name;
  string internal _symbol;
  string internal _description;

     
                                                              
     
  uint256 internal _count;

     
                                                       
     
  mapping(address => uint256[]) internal _assetsOf;

     
                                          
     
  mapping(uint256 => address) internal _holderOf;

     
                                                                        
     
  mapping(uint256 => uint256) internal _indexOfAsset;

     
                                             
     
  mapping(uint256 => string) internal _assetData;

     
                                                                               
                                                             
     
  mapping(address => mapping(address => bool)) internal _operators;

     
                           
     
  bool internal _reentrancy;
}

contract Storage is ProxyStorage, OwnableStorage, AssetRegistryStorage, LANDStorage {
}

contract Ownable is Storage {

  event OwnerUpdate(address _prevOwner, address _newOwner);

  function bytesToAddress (bytes b) pure public returns (address) {
    uint result = 0;
    for (uint i = b.length-1; i+1 > 0; i--) {
      uint c = uint(b[i]);
      uint to_inc = c * ( 16 ** ((b.length - i-1) * 2));
      result += to_inc;
    }
    return address(result);
  }

  modifier onlyOwner {
    assert(msg.sender == owner);
    _;
  }

  function initialize(bytes data) public {
    owner = bytesToAddress(data);
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != owner);
    owner = _newOwner;
  }
}

interface ILANDRegistry {

                                      
  function assignNewParcel(int x, int y, address beneficiary) public;
  function assignMultipleParcels(int[] x, int[] y, address beneficiary) public;

                                                                    
  function ping() public;
  function clearLand(int[] x, int[] y) public;

                         
  function encodeTokenId(int x, int y) view public returns (uint256);
  function decodeTokenId(uint value) view public returns (int, int);
  function exists(int x, int y) view public returns (bool);
  function ownerOfLand(int x, int y) view public returns (address);
  function ownerOfLandMany(int[] x, int[] y) view public returns (address[]);
  function landOf(address owner) view public returns (int[], int[]);
  function landData(int x, int y) view public returns (string);

                  
  function transferLand(int x, int y, address to) public;
  function transferManyLand(int[] x, int[] y, address to) public;

                
  function updateLandData(int x, int y, string data) public;
  function updateManyLandData(int[] x, int[] y, string data) public;
}

interface IAssetRegistry {

     
                                     
     
  function name() public view returns (string);
  function symbol() public view returns (string);
  function description() public view returns (string);
  function totalSupply() public view returns (uint256);

     
                                   
     
  function exists(uint256 assetId) public view returns (bool);

  function holderOf(uint256 assetId) public view returns (address);
  function safeHolderOf(uint256 assetId) public view returns (address);

  function assetData(uint256 assetId) public view returns (string);

     
                                    
     
  function assetCount(address holder) public view returns (uint256);
  function assetByIndex(address holder, uint256 index) public view returns (uint256);
  function assetsOf(address holder) external view returns (uint256[]);

     
                        
     
  function transfer(address to, uint256 assetId) public;
  function transfer(address to, uint256 assetId, bytes userData) public;
  function transfer(address to, uint256 assetId, bytes userData, bytes operatorData) public;

     
                             
     
  function authorizeOperator(address operator, bool authorized) public;

     
                          
     
  function isOperatorAuthorizedFor(address operator, address assetHolder)
    public view returns (bool);

     
           
     
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed assetId,
    address operator,
    bytes userData,
    bytes operatorData
  );
  event Update(
    uint256 indexed assetId,
    address indexed holder,
    address indexed operator,
    string data
  );
  event AuthorizeOperator(
    address indexed operator,
    address indexed holder,
    bool authorized
  );
}

contract EIP820 {
    InterfaceImplementationRegistry interfaceImplementationRegistry = InterfaceImplementationRegistry(0x94405C3223089A942B7597dB96Dc60FcA17B0E3A);

    function setInterfaceImplementation(string ifaceLabel, address impl) internal {
        interfaceImplementationRegistry.setInterfaceImplementer(this, keccak256(ifaceLabel), impl);
    }

    function interfaceAddr(address addr, string ifaceLabel) internal constant returns(address) {
        return interfaceImplementationRegistry.getInterfaceImplementer(addr, keccak256(ifaceLabel));
    }

    function delegateManagement(address newManager) internal {
        interfaceImplementationRegistry.changeManager(this, newManager);
    }
}

contract StandardAssetRegistry is AssetRegistryStorage, IAssetRegistry, EIP820 {
  using SafeMath for uint256;

    
                   
    

  function name() public view returns (string) {
    return _name;
  }

  function symbol() public view returns (string) {
    return _symbol;
  }

  function description() public view returns (string) {
    return _description;
  }

  function totalSupply() public view returns (uint256) {
    return _count;
  }

    
                                   
    

  function exists(uint256 assetId) public view returns (bool) {
    return _holderOf[assetId] != 0;
  }

  function holderOf(uint256 assetId) public view returns (address) {
    return _holderOf[assetId];
  }

  function safeHolderOf(uint256 assetId) public view returns (address) {
    address holder = _holderOf[assetId];
    require(holder != 0);
    return holder;
  }

  function assetData(uint256 assetId) public view returns (string) {
    return _assetData[assetId];
  }

  function safeAssetData(uint256 assetId) public view returns (string) {
    require(_holderOf[assetId] != 0);
    return _assetData[assetId];
  }

    
                                    
    

  function assetCount(address holder) public view returns (uint256) {
    return _assetsOf[holder].length;
  }

  function assetByIndex(address holder, uint256 index) public view returns (uint256) {
    require(index < _assetsOf[holder].length);
    require(index < (1<<127));
    return _assetsOf[holder][index];
  }

  function assetsOf(address holder) external view returns (uint256[]) {
    return _assetsOf[holder];
  }

    
                          
    

  function isOperatorAuthorizedFor(address operator, address assetHolder)
    public view returns (bool)
  {
    return _operators[assetHolder][operator];
  }

  function authorizeOperator(address operator, bool authorized) public {
    if (authorized) {
      require(!isOperatorAuthorizedFor(operator, msg.sender));
      _addAuthorization(operator, msg.sender);
    } else {
      require(isOperatorAuthorizedFor(operator, msg.sender));
      _clearAuthorization(operator, msg.sender);
    }
    AuthorizeOperator(operator, msg.sender, authorized);
  }

  function _addAuthorization(address operator, address holder) private {
    _operators[holder][operator] = true;
  }

  function _clearAuthorization(address operator, address holder) private {
    _operators[holder][operator] = false;
  }

    
                        
    

  function _addAssetTo(address to, uint256 assetId) internal {
    _holderOf[assetId] = to;

    uint256 length = assetCount(to);

    _assetsOf[to].push(assetId);

    _indexOfAsset[assetId] = length;

    _count = _count.add(1);
  }

  function _addAssetTo(address to, uint256 assetId, string data) internal {
    _addAssetTo(to, assetId);

    _assetData[assetId] = data;
  }

  function _removeAssetFrom(address from, uint256 assetId) internal {
    uint256 assetIndex = _indexOfAsset[assetId];
    uint256 lastAssetIndex = assetCount(from).sub(1);
    uint256 lastAssetId = _assetsOf[from][lastAssetIndex];

    _holderOf[assetId] = 0;

                                                                                             
    _assetsOf[from][assetIndex] = lastAssetId;

                       
    _assetsOf[from][lastAssetIndex] = 0;
    _assetsOf[from].length--;

                                                                        
    if (_assetsOf[from].length == 0) {
      delete _assetsOf[from];
    }

                                                  
    _indexOfAsset[assetId] = 0;
    _indexOfAsset[lastAssetId] = assetIndex;

    _count = _count.sub(1);
  }

  function _removeAssetData(uint256 assetId) internal {
    _assetData[assetId] = '';
  }

    
                              
    

  function _generate(uint256 assetId, address beneficiary, string data) internal {
    require(_holderOf[assetId] == 0);

    _addAssetTo(beneficiary, assetId, data);

    Transfer(0, beneficiary, assetId, msg.sender, bytes(data), '');
  }

  function _destroy(uint256 assetId) internal {
    address holder = _holderOf[assetId];
    require(holder != 0);

    _removeAssetFrom(holder, assetId);
    _removeAssetData(assetId);

    Transfer(holder, 0, assetId, msg.sender, '', '');
  }

    
                                   
    

  modifier onlyHolder(uint256 assetId) {
    require(_holderOf[assetId] == msg.sender);
    _;
  }

  modifier onlyOperatorOrHolder(uint256 assetId) {
    require(_holderOf[assetId] == msg.sender
         || isOperatorAuthorizedFor(msg.sender, _holderOf[assetId]));
    _;
  }

  modifier isDestinataryDefined(address destinatary) {
    require(destinatary != 0);
    _;
  }

  modifier destinataryIsNotHolder(uint256 assetId, address to) {
    require(_holderOf[assetId] != to);
    _;
  }

  function transfer(address to, uint256 assetId) public {
    return _doTransfer(to, assetId, '', 0, '');
  }

  function transfer(address to, uint256 assetId, bytes userData) public {
    return _doTransfer(to, assetId, userData, 0, '');
  }

  function transfer(address to, uint256 assetId, bytes userData, bytes operatorData) public {
    return _doTransfer(to, assetId, userData, msg.sender, operatorData);
  }

  function _doTransfer(
    address to, uint256 assetId, bytes userData, address operator, bytes operatorData
  )
    isDestinataryDefined(to)
    destinataryIsNotHolder(assetId, to)
    onlyOperatorOrHolder(assetId)
    internal
  {
    return _doSend(to, assetId, userData, operator, operatorData);
  }


  function _doSend(
    address to, uint256 assetId, bytes userData, address operator, bytes operatorData
  )
    internal
  {
    address holder = _holderOf[assetId];
    _removeAssetFrom(holder, assetId);
    _addAssetTo(to, assetId);

    if (_isContract(to)) {
      require(!_reentrancy);
      _reentrancy = true;

      address recipient = interfaceAddr(to, 'IAssetHolder');
      require(recipient != 0);

      IAssetHolder(recipient).onAssetReceived(assetId, holder, to, userData, operator, operatorData);

      _reentrancy = false;
    }

    Transfer(holder, to, assetId, operator, userData, operatorData);
  }

    
                             
    

  function _update(uint256 assetId, string data) internal {
    require(exists(assetId));
    _assetData[assetId] = data;
    Update(assetId, _holderOf[assetId], msg.sender, data);
  }

    
              
    

  function _isContract(address addr) internal view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
}

contract LANDRegistry is Storage,
  Ownable, StandardAssetRegistry,
  ILANDRegistry
{

  function initialize(bytes data) public {
    _name = 'Decentraland LAND';
    _symbol = 'LAND';
    _description = 'Contract that stores the Decentraland LAND registry';
    owner = 0x55ed2910cc807e4596024266ebdf7b1753405a11;
  }

  function authorizeDeploy(address beneficiary) public onlyOwner {
    authorizedDeploy[beneficiary] = true;
  }
  function forbidDeploy(address beneficiary) public onlyOwner {
    authorizedDeploy[beneficiary] = false;
  }

  function assignNewParcel(int x, int y, address beneficiary) public {
    require(authorizedDeploy[msg.sender]);
    _generate(encodeTokenId(x, y), beneficiary, '');
  }

  function assignMultipleParcels(int[] x, int[] y, address beneficiary) public {
    require(authorizedDeploy[msg.sender]);
    for (uint i = 0; i < x.length; i++) {
      _generate(encodeTokenId(x[i], y[i]), beneficiary, '');
    }
  }

  function destroy(uint256 assetId) onlyOwner public {
    _destroy(assetId);
  }

    
                                              
    

  function ping() public {
    latestPing[msg.sender] = now;
  }

  function setLatestToNow(address user) onlyOwner public {
    latestPing[user] = now;
  }

  function multiplePing(address[] users) public {
    require(authorizedDeploy[msg.sender]);
    for (uint i = 0; i < users.length; i++) {
      latestPing[users[i]] = now;
    }
  }

  function clearLand(int[] x, int[] y) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      uint landId = encodeTokenId(x[i], y[i]);
      address holder = holderOf(landId);
      if (latestPing[holder] < now - 1 years) {
        _destroy(landId);
      }
    }
  }

                                  
  function decimals() view public returns (uint8) {
    return 0;
  }

  function balanceOf(address user) view public returns (uint256) {
    return assetCount(user);
  }

    
                 
    

  function encodeTokenId(int x, int y) view public returns (uint) {
    return ((uint(x) * factor) & clearLow) | (uint(y) & clearHigh);
  }

  function decodeTokenId(uint value) view public returns (int, int) {
    uint x = (value & clearLow) >> 128;
    uint y = (value & clearHigh);
    return (expandNegative128BitCast(x), expandNegative128BitCast(y));
  }

  function expandNegative128BitCast(uint value) view public returns (int) {
    if (value & (1<<127) != 0) {
      return int(value | clearLow);
    }
    return int(value);
  }

  function exists(int x, int y) view public returns (bool) {
    return exists(encodeTokenId(x, y));
  }

  function ownerOfLand(int x, int y) view public returns (address) {
    return holderOf(encodeTokenId(x, y));
  }

  function ownerOfLandMany(int[] x, int[] y) view public returns (address[]) {
    require(x.length > 0);
    require(x.length == y.length);

    address[] memory addrs = new address[](x.length);
    for (uint i = 0; i < x.length; i++) {
      addrs[i] = ownerOfLand(x[i], y[i]);
    }

    return addrs;
  }

  function landOf(address owner) public view returns (int[], int[]) {
    int[] memory x = new int[](_assetsOf[owner].length);
    int[] memory y = new int[](_assetsOf[owner].length);

    int assetX;
    int assetY;
    uint length = _assetsOf[owner].length;
    for (uint i = 0; i < length; i++) {
      (assetX, assetY) = decodeTokenId(_assetsOf[owner][i]);
      x[i] = assetX;
      y[i] = assetY;
    }

    return (x, y);
  }

  function landData(int x, int y) view public returns (string) {
    return assetData(encodeTokenId(x, y));
  }

    
                  
    

  function transferLand(int x, int y, address to) public {
    transfer(to, encodeTokenId(x, y));
  }

  function transferManyLand(int[] x, int[] y, address to) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      transfer(to, encodeTokenId(x[i], y[i]));
    }
  }

    
                
    

  function updateLandData(int x, int y, string data) public onlyOperatorOrHolder(encodeTokenId(x, y)) {
    return _update(encodeTokenId(x, y), data);
  }

  function updateManyLandData(int[] x, int[] y, string data) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      updateLandData(x[i], y[i], data);
    }
  }
}