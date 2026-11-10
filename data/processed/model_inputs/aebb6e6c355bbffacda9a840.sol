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

contract TaylorTokenTGE is Ownable {
  using SafeMath for uint256;

  uint256 constant internal DECIMAL_CASES = 10**18;
  TaylorToken public token;

  uint256 constant public FOUNDERS = 10**6 * DECIMAL_CASES;
  uint256 constant public ADVISORS = 4 * 10**5 * DECIMAL_CASES;
  uint256 constant public TEAM = 3 * 10**5 * DECIMAL_CASES;
  uint256 constant public REFERRAL_PROGRAMS = 7 * 10**5 * DECIMAL_CASES;
  uint256 constant public PRESALE = 1190476 * DECIMAL_CASES;
  uint256 constant public PUBLICSALE = 6409524 * DECIMAL_CASES;

  address public founders_address;
  address public advisors_address;
  address public team_address;
  address public referral_address;
  address public presale_address;
  address public publicsale_address;

     
                                                                     
                                                                           
                                                                                  
                                                                                  
                                                                          
                                                                                  
                                                                            
                                                                 
     
  function setUp(address _token, address _founders, address _advisors, address _team, address _referral, address _presale, address _publicSale) public onlyOwner{
    token = TaylorToken(_token);
    founders_address = _founders;
    advisors_address = _advisors;
    team_address = _team;
    referral_address = _referral;
    presale_address = _presale;
    publicsale_address = _publicSale;
  }

     
                                                                                            
     
  function distribute() public onlyOwner {
    uint256 total = FOUNDERS.add(ADVISORS).add(TEAM).add(REFERRAL_PROGRAMS).add(PRESALE).add(PUBLICSALE);
    require(total >= token.balanceOf(this));
    token.transfer(founders_address, FOUNDERS);
    token.transfer(advisors_address, ADVISORS);
    token.transfer(team_address, TEAM);
    token.transfer(referral_address, REFERRAL_PROGRAMS);
    token.transfer(presale_address, PRESALE);
    token.transfer(publicsale_address, PUBLICSALE);
  }

}