contract CrowdFundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;
  uint256 nextIdx;
  
  function refundSafe() public {
    uint256 i = nextIdx;
    while(i < refundAddresses.length && msg.gas > 200000) {
      refundAddresses[i].transfer(refundAmount[i]);
      i++;
    }
    nextIdx = i;
  }
}