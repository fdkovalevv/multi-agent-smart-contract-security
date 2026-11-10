contract DgxSwap {

  uint256 public totalCount;
  mapping (address => address) public swapContracts;
  mapping (uint256 => address) public sellers;

  function DgxSwap() {
    totalCount = 0;
  }

  function createSwap(uint256 _weiprice) public returns (bool _success) {
    address _swapcontract = new SwapContract(msg.sender, _weiprice);
    swapContracts[msg.sender] = _swapcontract;
    sellers[totalCount] = msg.sender; 
    totalCount++;
    _success = true;
    return _success;
  }

  function getSwap(uint256 _id) public constant returns (address _seller, address _contract, uint256 _dgxbalance, uint256 _weiprice, uint256 _totalweiprice) {
    _seller = sellers[_id];
    if (_seller == 0x0000000000000000000000000000000000000000) {
      _contract = 0x0000000000000000000000000000000000000000;
      _dgxbalance = 0;
      _weiprice = 0;
      _totalweiprice = 0;
    } else {
      _contract = swapContracts[_seller];  
      _dgxbalance = SwapContract(_contract).dgxBalance();
      _weiprice = SwapContract(_contract).weiPrice();
      _totalweiprice = SwapContract(_contract).totalWeiPrice();
    }
    return (_seller, _contract, _dgxbalance, _weiprice, _totalweiprice);
  }

}