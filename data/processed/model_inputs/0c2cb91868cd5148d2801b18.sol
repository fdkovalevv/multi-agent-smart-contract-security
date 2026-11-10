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

  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract DividendManager is Ownable {
    
    using SafeMath for uint256;
    
    uint256 public dividends_share;
    uint256 public reinvestment_share;
    
    SingleTokenCoin token;
    AuthAdmin authAdmin;

    mapping (address => uint256) public dividends;

    event PaymentAvailable(address addr, uint256 amount);
    event DividendPayment(uint256 dividend_per_token, uint256 timestamp);
    event DevidendsSnapshot(address _addr, uint256 _value);
    event ReinvestmentWithdrawal(address _owner, uint256 _value);
    
    modifier adminOnly {
        require (authAdmin.isCurrentAdmin(msg.sender));
        _;
    }
    
    function DividendManager(address token_address, address auth_address) public {
        token = SingleTokenCoin(token_address);
        set_new_admin(auth_address);
        dividends_share = 50;
        reinvestment_share = 50;
    }

    function () public payable{
                                     
        uint256 funds_for_dividends = msg.value.mul(dividends_share).div(100);
        uint256 dividend_per_token = funds_for_dividends.div(token.totalSupply());
        require (dividend_per_token != 0);
        uint256 totalPaidOut = 0;
        for (uint256 i = 0; i < token.count_token_holders(); i++) {
            address addr = token.tokenHolder(i);
            if (token.balanceOf(addr) < 1000E6) {
                uint256 dividends_before_commision = dividend_per_token.mul(token.balanceOf(addr));    
                uint256 dividends_after_commision = dividends_before_commision.mul(85).div(100);
            } else if (token.balanceOf(addr) > 1000E6) {
                dividends_before_commision = dividend_per_token.mul(token.balanceOf(addr));
                dividends_after_commision = dividends_before_commision.mul(925).div(1000);
            }
            dividends[addr] = dividends[addr].add(dividends_after_commision);
            PaymentAvailable(addr, dividends_after_commision);
            totalPaidOut = totalPaidOut.add(dividends_after_commision);
        }
        DividendPayment(dividend_per_token, now);
                                                           
                                                                  
                                                                        
                                                   
    }

    function set_new_admin (address admin_address) public onlyOwner {
        authAdmin = AuthAdmin(admin_address);
    }

    function set_new_dividend_share (uint256 new_dividends_share) public adminOnly {
        require (new_dividends_share > 0 && new_dividends_share <= 100);
        dividends_share = new_dividends_share;
        reinvestment_share = 100 - dividends_share;                                                                                                                                                                                                                                                                                                                                                                                
    }
    
    function withdrawDividend() public {
        require (dividends[msg.sender] != 0);

        uint256 amount = dividends[msg.sender];
        dividends[msg.sender] = 0;
        msg.sender.transfer(amount);
        DevidendsSnapshot(msg.sender, amount);
    }
    
    function get_funds_left_for_reinvestment () public onlyOwner {
        ReinvestmentWithdrawal(owner, this.balance);
        msg.sender.transfer(this.balance);
    }
}