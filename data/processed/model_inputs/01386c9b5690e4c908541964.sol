contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  function Ownable() public{
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

contract Crowdsale is Ownable {
    
    using SafeMath for uint;
    WAEP public token ;
    uint start;        
    uint end;        
    uint softcapUSD;
    uint hardcapUSD;
    uint public risedUSD;
    uint hardcapTokens;
    uint oneTokenInWei;
    uint sale1 = 1000000*10**18;
    uint sale2 = 2000000*10**18;
    uint sale3 = 3000000*10**18;

    mapping (address => bool) refunded;
    mapping (address => uint256) saleBalances ;  
    function Crowdsale() public{
        owner = msg.sender;
        start = 1513339200;        
        end = 1518696000;        
        softcapUSD = 350000*10**18;
        hardcapUSD = 3500000*10**18;
        hardcapTokens = 1000000000*10**18;
		oneTokenInWei = 1532355690402860;                                  
		token = new WAEP();
    }
    
    function setEthPrice(uint _new) onlyOwner {
        oneTokenInWei = _new;
    }
    
    function buyByBot(uint _usd, uint _tokens, address _to) onlyOwner {
        require( risedUSD + _usd < hardcapUSD );
        risedUSD += _usd*10**18;
        token.mint(_to, _tokens*10**18);
    }
    
    function() external payable {
        require(now > start && now < end);
        require( risedUSD + msg.value.mul(10**18).div(oneTokenInWei) < hardcapUSD );
        uint discountPrice ;
        
        if ( risedUSD < sale1 ) {                
            discountPrice = oneTokenInWei.div(100).mul(60);
        } else if ( risedUSD < sale2 ) {                
            discountPrice = oneTokenInWei.div(100).mul(70);
        } else if ( risedUSD < sale3 ) {                
            discountPrice = oneTokenInWei.div(100).mul(80);
        } else {
           discountPrice = oneTokenInWei ;
        }

        uint256 tokenAdd = msg.value.mul(10**18).div(discountPrice);
        require(token.totalSupply() + tokenAdd < hardcapTokens);
        risedUSD += msg.value.mul(10**18).div(oneTokenInWei);
        saleBalances[msg.sender] = saleBalances[msg.sender].add(msg.value);
        token.mint(msg.sender, tokenAdd);
    }
    
    function getEth() public onlyOwner {
        owner.transfer(this.balance);
    }
    
    function mint(address _to, uint _value) public onlyOwner {
        require(_value > 0);
        token.mint(_to, _value*10**18);
    }

    function refund() public {
        require (now > end  && risedUSD < softcapUSD );
        require (!refunded[msg.sender]);
        require (saleBalances[msg.sender] != 0) ;
        uint refund = saleBalances[msg.sender];
        require(msg.sender.send(refund));
        refunded[msg.sender] = true;
    }
}