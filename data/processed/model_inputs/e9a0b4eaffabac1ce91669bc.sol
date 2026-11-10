contract Ownable {
  address public owner;
  address public newOwner;
  event OwnershipTransferred(address indexed _from, address indexed _to);
  function Ownable() public {
    owner = msg.sender;
  }
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address _newOwner) public onlyOwner {
    newOwner = _newOwner;
  }

  function acceptOwnership() public {
    require(msg.sender == newOwner);
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
  
}

contract AirdropMeth is Ownable{
    ERC20 public token;
    address public creator;
    
    event LogAccountAmount(address indexed user, uint256 indexed amount);

    function AirdropMeth(address _token) public {
        token = ERC20(_token);
        owner = msg.sender;
    }

    function setToken(address _token) public {
        token = ERC20(_token);
    }

                                                                                 
                            
    function startAirdropFrom(address _fromAddr, address[] users, uint256 amounts) public onlyOwner {
        for(uint256 i = 0; i < users.length; i++) {
            
            LogAccountAmount(users[i], amounts);

            token.transferFrom(_fromAddr, users[i], amounts);
        }
    }
    
    function startAirdrop(address[] _user, uint256 _amount) public onlyOwner {
    	for(uint256 i = 0; i < _user.length; i++) {
        	token.transfer(_user[i], _amount);
        }
    }
    function removeContract() public onlyOwner {
            selfdestruct(msg.sender);
            
        }
}