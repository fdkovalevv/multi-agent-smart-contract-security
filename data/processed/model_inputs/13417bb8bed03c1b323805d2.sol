contract SafeMath {
             

  function safeMul(uint256 a, uint256 b) internal returns (uint256 c) {
    c = a * b;
    assert(a == 0 || c / a == b);
  }

  function safeSub(uint256 a, uint256 b) internal returns (uint256 c) {
    assert(b <= a);
    c = a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal returns (uint256 c) {
    c = a + b;
    assert(c>=a && c>=b);
  }

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

contract ProfitContainerAdapter is SafeMath{
    
    address owner;
    address shopLocation;
    address shopKeeperLocation;
    address profitContainerLocation;
    
    modifier owned(){
        assert(msg.sender == owner);
        _;
    }
    
    function changeShop(address newShop) owned {
        shopLocation = newShop;
    }
    
    
    function changeKeeper(address newKeeper) owned {
        shopKeeperLocation = newKeeper;
    }
    
    
    function changeContainer(address newContainer) owned {
        profitContainerLocation = newContainer;
    }
    
    function ProfitContainerAdapter(address sL, address sKL, address pCL){
        owner = msg.sender;
        shopLocation = sL;
        shopKeeperLocation = sKL;
        profitContainerLocation = pCL;
    }
    
    function takeEtherProfits(){
        ShopKeeper(shopKeeperLocation).splitProfits();
        ValueTrader shop = ValueTrader(shopLocation);
        shop.buyEther(shop.balanceOf(this));
        assert(profitContainerLocation.call.value(this.balance)());
    }
    
                                                                                              
    function takeTokenProfits(address token){
        ShopKeeper(shopKeeperLocation).splitProfits();
        ValueTrader shop = ValueTrader(shopLocation);
        shop.buyToken(token,shop.balanceOf(this));
        assert(Token(token).transfer(profitContainerLocation,Token(token).balanceOf(this)));
    }
    
    function giveAwayHoldership(address holderB) owned {
        ShopKeeper(shopKeeperLocation).giveAwayOwnership(holderB);
    }
    
    function giveAwayOwnership(address newOwner) owned {
        owner = newOwner;
    }
    
}