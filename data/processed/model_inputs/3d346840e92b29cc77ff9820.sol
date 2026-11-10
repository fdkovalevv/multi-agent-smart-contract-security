contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


     
                                                                                         
             
     
  constructor() public {
    owner = msg.sender;
  }

     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
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
}

contract ReadsAzimuth
{
                                            
    
  Azimuth public azimuth;

                                                            
    
  constructor(Azimuth _azimuth)
    public
  {
    azimuth = _azimuth;
  }

                                                                          
                                                   
    
  modifier activePointOwner(uint32 _point)
  {
    require( azimuth.isOwner(_point, msg.sender) &&
             azimuth.isActive(_point) );
    _;
  }

                                                                       
                                                     
    
  modifier activePointManager(uint32 _point)
  {
    require( azimuth.canManage(_point, msg.sender) &&
             azimuth.isActive(_point) );
    _;
  }
}

contract EclipticBase is Ownable, ReadsAzimuth
{
                                                 
    
  event Upgraded(address to);

                                   
    
  Polls public polls;

                                                             
                                                                    
                                                                       
    
  address public previousEcliptic;

  constructor( address _previous,
               Azimuth _azimuth,
               Polls _polls )
    ReadsAzimuth(_azimuth)
    internal
  {
    previousEcliptic = _previous;
    polls = _polls;
  }

                                                             
    
                                                               
                                             
                                                                      
    
  function onUpgrade()
    external
  {
                                                    
                                                        
      
    require( msg.sender == previousEcliptic &&
             this == azimuth.owner() &&
             this == polls.owner() );
  }

                                                                   
                                                                  
    
                                                                 
                                                
    
  function upgrade(EclipticBase _new)
    internal
  {
                                                
      
    azimuth.transferOwnership(_new);
    polls.transferOwnership(_new);

                                                    
      
    _new.onUpgrade();

                                            
      
    emit Upgraded(_new);
    selfdestruct(_new);
  }
}