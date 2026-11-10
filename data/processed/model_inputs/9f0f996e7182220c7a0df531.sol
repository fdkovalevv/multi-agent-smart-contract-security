contract Owned {

    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed by, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);
    event OwnershipRemoved();

                                                                                
    function Owned() public {
        owner = msg.sender;
    }

                                                                           
                
    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }
    
                                                                                
                                                                                
                                          
                                                                             
                  
                                                                             
    function proposeOwnership(address _newOwnerCandidate) public onlyOwner {
        newOwnerCandidate = _newOwnerCandidate;
        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

                                                                          
                              
    function acceptOwnership() public {
        require(msg.sender == newOwnerCandidate);

        address oldOwner = owner;
        owner = newOwnerCandidate;
        newOwnerCandidate = 0x0;

        OwnershipTransferred(oldOwner, owner);
    }

                                                                              
                                                                             
                                                                                
                                                     
    function changeOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != 0x0);

        address oldOwner = owner;
        owner = _newOwner;
        newOwnerCandidate = 0x0;

        OwnershipTransferred(oldOwner, owner);
    }

                                                                              
                                                                               
                                                                               
                                                                            
                                                                       
    function removeOwnership(address _dac) public onlyOwner {
        require(_dac == 0xdac);
        owner = 0x0;
        newOwnerCandidate = 0x0;
        OwnershipRemoved();     
    }
}

contract Escapable is Owned {
    address public escapeHatchCaller;
    address public escapeHatchDestination;
    mapping (address=>bool) private escapeBlacklist;                            

                                                                            
                            
                                                                              
                                                                          
                                                                            
                                                          
                                                                            
                                                                                
                                                    
                                                    
    function Escapable(address _escapeHatchCaller, address _escapeHatchDestination) public {
        escapeHatchCaller = _escapeHatchCaller;
        escapeHatchDestination = _escapeHatchDestination;
    }

                                                                        
                                                                           
    modifier onlyEscapeHatchCallerOrOwner {
        require ((msg.sender == escapeHatchCaller)||(msg.sender == owner));
        _;
    }

                                                                             
                                                                               
                                                                               
                                                                           
    function blacklistEscapeToken(address _token) internal {
        escapeBlacklist[_token] = true;
        EscapeHatchBlackistedToken(_token);
    }

                                                                       
                                                     
                                                                               
                                             
    function isTokenEscapable(address _token) constant public returns (bool) {
        return !escapeBlacklist[_token];
    }

                                                                               
                                                                    
                                                    
    function escapeHatch(address _token) public onlyEscapeHatchCallerOrOwner {   
        require(escapeBlacklist[_token]==false);

        uint256 balance;

                                
        if (_token == 0x0) {
            balance = this.balance;
            escapeHatchDestination.transfer(balance);
            EscapeHatchCalled(_token, balance);
            return;
        }
                                 
        ERC20 token = ERC20(_token);
        balance = token.balanceOf(this);
        require(token.transfer(escapeHatchDestination, balance));
        EscapeHatchCalled(_token, balance);
    }

                                                                    
                                                                        
                                                                               
                                                                                 
                                                          
    function changeHatchEscapeCaller(address _newEscapeHatchCaller) public onlyEscapeHatchCallerOrOwner {
        escapeHatchCaller = _newEscapeHatchCaller;
    }

    event EscapeHatchBlackistedToken(address token);
    event EscapeHatchCalled(address token, uint amount);
}

contract TokenController {
                                                                             
                                                                      
                                                                 
    function proxyPayment(address _owner) public payable returns(bool);

                                                                           
                                       
                                               
                                                  
                                                 
                                                                       
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

                                                                      
                                       
                                                        
                                                           
                                                         
                                                                       
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);
}

contract LPPCampaign is Escapable, TokenController {
    uint constant FROM_OWNER = 0;
    uint constant FROM_PROPOSEDPROJECT = 255;
    uint constant TO_OWNER = 256;
    uint constant TO_PROPOSEDPROJECT = 511;

    LiquidPledging public liquidPledging;
    MiniMeToken public token;
    bool public initPending;
    uint64 public idProject;
    address public reviewer;
    address public newReviewer;

    event GenerateTokens(address indexed liquidPledging, address addr, uint amount);

    function LPPCampaign(
        LiquidPledging _liquidPledging,
        string tokenName,
        string tokenSymbol,
        address _escapeHatchCaller,
        address _escapeHatchDestination
    ) Escapable(_escapeHatchCaller, _escapeHatchDestination) public
    {
      require(msg.sender != tx.origin);
      liquidPledging = _liquidPledging;
      MiniMeTokenFactory tokenFactory = new MiniMeTokenFactory();
      token = new MiniMeToken(tokenFactory, 0x0, 0, tokenName, 18, tokenSymbol, false);
      initPending = true;
    }

    function init(
        string name,
        string url,
        uint64 parentProject,
        address _reviewer
    ) {
        require(initPending);
        idProject = liquidPledging.addProject(name, url, address(this), parentProject, 0, ILiquidPledgingPlugin(this));
        reviewer = _reviewer;
        initPending = false;
    }

    modifier initialized() {
      require(!initPending);
      _;
    }

    modifier onlyReviewer() {
        require(msg.sender == reviewer);
        _;
    }

    modifier onlyOwnerOrReviewer() {
        require( msg.sender == owner || msg.sender == reviewer );
        _;
    }

    function changeReviewer(address _newReviewer) public initialized onlyReviewer {
        newReviewer = _newReviewer;
    }

    function acceptNewReviewer() public initialized {
        require(newReviewer == msg.sender);
        reviewer = newReviewer;
        newReviewer = 0;
    }

    function beforeTransfer(
        uint64 pledgeAdmin,
        uint64 pledgeFrom,
        uint64 pledgeTo,
        uint64 context,
        uint amount
    ) external initialized returns (uint maxAllowed) {
        require(msg.sender == address(liquidPledging));
        var (, , , fromProposedProject , , , ) = liquidPledging.getPledge(pledgeFrom);
        var (, , , , , , toPledgeState ) = liquidPledging.getPledge(pledgeTo);

                                           
        if ( (context == TO_OWNER) && (toPledgeState != LiquidPledgingBase.PledgeState.Pledged) ) return 0;

                                                                                                    
                                                                            
        if ( (context == TO_PROPOSEDPROJECT)
            || ( (context == TO_OWNER) && (fromProposedProject != idProject) ))
        {
            if (isCanceled()) return 0;
        }
        return amount;
    }

    function afterTransfer(
        uint64 pledgeAdmin,
        uint64 pledgeFrom,
        uint64 pledgeTo,
        uint64 context,
        uint amount
    ) external initialized {
      require(msg.sender == address(liquidPledging));
      var (, , , , , , toPledgeState) = liquidPledging.getPledge(pledgeTo);
      var (, fromOwner, , , , , ) = liquidPledging.getPledge(pledgeFrom);

                                                                    
      if ( (context == TO_OWNER) &&
              (toPledgeState == LiquidPledgingBase.PledgeState.Pledged)) {
        var (, fromAddr , , , , , , ) = liquidPledging.getPledgeAdmin(fromOwner);

        token.generateTokens(fromAddr, amount);
        GenerateTokens(liquidPledging, fromAddr, amount);
      }
    }

    function cancelCampaign() public initialized onlyOwnerOrReviewer {
        require( !isCanceled() );

        liquidPledging.cancelProject(idProject);
    }

    function transfer(uint64 idPledge, uint amount, uint64 idReceiver) public initialized onlyOwner {
      require( !isCanceled() );

      liquidPledging.transfer(idProject, idPledge, amount, idReceiver);
    }

    function isCanceled() public constant initialized returns (bool) {
      return liquidPledging.isProjectCanceled(idProject);
    }

                                                              
                                                                         
                                                                  
                                                                         
                
    function sendTransaction(address destination, uint value, bytes data) public initialized onlyOwner {
      require(destination.call.value(value)(data));
    }

                
                  
                

                                                                           
                                                                    
                                                               
  function proxyPayment(address _owner) public payable initialized returns(bool) {
    return false;
  }

                                                                         
                                     
                                             
                                                
                                               
                                                                     
  function onTransfer(address _from, address _to, uint _amount) public initialized returns(bool) {
    return false;
  }

                                                                    
                                     
                                                      
                                                         
                                                       
                                                                     
  function onApprove(address _owner, address _spender, uint _amount) public initialized returns(bool) {
    return false;
  }
}