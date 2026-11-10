contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }


     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ZillaCrowdsale is Ownable {
  using SafeMath for uint256;

                  
  event StartCrowdsale();
  event FinalizeCrowdsale();
  event TokenSold(address recipient, uint eth_amount, uint zla_amount);
 
                        
  uint256 constant presale_eth_to_zilla   = 1200;
  uint256 constant crowdsale_eth_to_zilla =  750;

                            
  ZillaToken public token;

                          
  uint256 public zilla_remaining;

                                     
  address public vault;

                    
  enum CrowdsaleState { Waiting, Running, Ended }
  CrowdsaleState public state = CrowdsaleState.Waiting;
  uint256 public start;
  uint256 public unlimited;
  uint256 public end;

                       
  struct Participant {
    bool    whitelist;
    uint256 remaining;
  }
  mapping (address => Participant) private participants;

     
                                   
     
  function ZillaCrowdsale() public {
    token = new ZillaToken();
    zilla_remaining = token.totalSupply();
  }

     
                                                                     
     
  modifier isStarted() {
    require( (state == CrowdsaleState.Running) );
    _;
  }

     
                                                          
     
  modifier isRunning() {
    require( (state == CrowdsaleState.Running) && (now >= start) && (now < end) );
    _;
  }

     
                                   
                                                         
                                                     
                                                                       
     
  function startCrowdsale(uint256 _start, uint256 _unlimited, uint256 _end, address _vault) public onlyOwner {
    require(state == CrowdsaleState.Waiting);
    require(_start >= now);
    require(_unlimited > _start);
    require(_unlimited < _end);
    require(_end > _start);
    require(_vault != 0x0);

    start     = _start;
    unlimited = _unlimited;
    end       = _end;
    vault     = _vault;
    state     = CrowdsaleState.Running;
    StartCrowdsale();
  }

     
                                                                                    
     
  function finalizeCrowdsale() public onlyOwner {
    require(state == CrowdsaleState.Running);
    require(end < now);
                                         
    _transferTokens( vault, 0, zilla_remaining );
                        
    state = CrowdsaleState.Ended;
                                   
    token.allowTrading();
    FinalizeCrowdsale();
  }

     
                                                                                                         
                                                   
     
  function setEndDate(uint256 _end) public onlyOwner {
    require(state == CrowdsaleState.Running);
    require(_end > now);
    require(_end > start);
    require(_end > end);

    end = _end;
  }

     
                                                   
                                                         
     
  function setVault(address _vault) public onlyOwner {
    require(_vault != 0x0);

    vault = _vault;    
  }

     
                                             
                                                                 
     
  function whitelistAdd(address[] _addresses) public onlyOwner {
    for (uint i=0; i<_addresses.length; i++) {
      Participant storage p = participants[ _addresses[i] ];
      p.whitelist = true;
      p.remaining = 15 ether;
    }
  }

     
                                                  
                                                                      
     
  function whitelistRemove(address[] _addresses) public onlyOwner {
    for (uint i=0; i<_addresses.length; i++) {
      delete participants[ _addresses[i] ];
    }
  }

     
                                                             
     
  function() external payable {
    buyTokens(msg.sender);
  }

     
                                                                  
                                                                  
     
  function _allocateTokens(uint256 eth) private view returns(uint256 tokens) {
    tokens = crowdsale_eth_to_zilla.mul(eth);
    require( zilla_remaining >= tokens );
  }

     
                                                                      
                                                                    
     
  function _allocatePresaleTokens(uint256 eth) private view returns(uint256 tokens) {
    tokens = presale_eth_to_zilla.mul(eth);
    require( zilla_remaining >= tokens );
  }

     
                                                                             
                                                      
                                             
                                                    
     
  function _transferTokens(address recipient, uint256 eth, uint256 zla) private {
    require( token.crowdsaleTransfer( recipient, zla ) );
    zilla_remaining = zilla_remaining.sub( zla );
    TokenSold(recipient, eth, zla);
  }

     
                                                                      
                                                       
                                                     
     
  function _grantPresaleTokens(address recipient, uint256 eth) private {
    uint256 tokens = _allocatePresaleTokens(eth);
    _transferTokens( recipient, eth, tokens );
  }

     
                                                             
                                                       
     
  function buyTokens(address recipient) public isRunning payable {
    Participant storage p = participants[ recipient ];    
    require( p.whitelist );
                                             
    if( unlimited > now ) {
      require( p.remaining >= msg.value );
      p.remaining.sub( msg.value );
    }
    uint256 tokens = _allocateTokens(msg.value);
    require( vault.send(msg.value) );
    _transferTokens( recipient, msg.value, tokens );
  }

     
                                                         
                                                        
                                                  
     
  function grantTokens(address recipient, uint256 zla) public isStarted onlyOwner {
    require( zilla_remaining >= zla );
    _transferTokens( recipient, 0, zla );
  }

     
                                                                      
                                                              
                                                 
     
  function grantPresaleTokens(address[] recipients, uint256[] eths) public isStarted onlyOwner {
    require( recipients.length == eths.length );
    for (uint i=0; i<recipients.length; i++) {
      _grantPresaleTokens( recipients[i], eths[i] );
    }
  }

}