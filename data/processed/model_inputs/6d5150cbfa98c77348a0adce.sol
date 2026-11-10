contract Ownable {
  address public owner;
  address public admin;
  uint256 public lockedIn;
  uint256 public OWNER_AMOUNT;
  uint256 public OWNER_PERCENT = 2;
  uint256 public OWNER_MIN = 0.0001 ether;
  
  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


     
                                                                                         
             
     
  constructor(address addr, uint256 percent, uint256 min) public {
    require(addr != address(0), 'invalid addr');
    owner = msg.sender;
    admin = addr;
    OWNER_PERCENT = percent;
    OWNER_MIN = min;
  }

     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender==owner || msg.sender==admin);
    _;
  }

     
                                                                         
                                                                              
                                                                       
                      
     
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

     
                                                                                     
                                                           
     
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

     
                                                          
                                                           
     
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

  function _cash() public view returns(uint256){
      return address(this).balance;
  }

  function kill() onlyOwner public{
    require(lockedIn == 0, "invalid lockedIn");
    selfdestruct(owner);
  }
  
  function setAdmin(address addr) onlyOwner public{
      require(addr != address(0), 'invalid addr');
      admin = addr;
  }
  
  function setOwnerPercent(uint256 percent) onlyOwner public{
      OWNER_PERCENT = percent;
  }
  
  function setOwnerMin(uint256 min) onlyOwner public{
      OWNER_MIN = min;
  }
  
  function _fee() internal returns(uint256){
      uint256 fe = msg.value*OWNER_PERCENT/100;
      if(fe < OWNER_MIN){
          fe = OWNER_MIN;
      }
      OWNER_AMOUNT += fe;
      return fe;
  }
  
  function cashOut() onlyOwner public{
    require(OWNER_AMOUNT > 0, 'invalid OWNER_AMOUNT');
    owner.send(OWNER_AMOUNT);
  }

  modifier isHuman() {
      address _addr = msg.sender;
      uint256 _codeLength;
      assembly {_codeLength := extcodesize(_addr)}
      require(_codeLength == 0, "sorry humans only");
      _;
  }

  modifier isContract() {
      address _addr = msg.sender;
      uint256 _codeLength;
      assembly {_codeLength := extcodesize(_addr)}
      require(_codeLength > 0, "sorry contract only");
      _;
  }
}