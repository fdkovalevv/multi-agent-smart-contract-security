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

contract IntermediateWallet is Ownable {

  address public wallet;

  function IntermediateWallet() public {
    wallet = 0x246a8bC2bC20826Ba19D8F7FC5799fF69A79388d;
  }

  function setWallet(address newWallet) public onlyOwner {
    wallet = newWallet;
  }

  function retrieveTokens(address to, address anotherToken) public onlyOwner {
    ERC20Basic alienToken = ERC20Basic(anotherToken);
    alienToken.transfer(to, alienToken.balanceOf(this));
  }

  function () payable public {
    wallet.transfer(msg.value);
  }

}