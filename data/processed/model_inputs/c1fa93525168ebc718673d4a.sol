contract BATSafe {
  mapping (address => uint256) allocations;
  uint256 public unlockDate;
  address public BAT;
  uint256 public constant exponent = 10**18;

  function BATSafe(address _BAT) {
    BAT = _BAT;
    unlockDate = now + 6 * 30 days;
    allocations[0xc504E7BF907fccc389d08A1C302d03B7baB4E5DC] = 2000000;
    allocations[0x2Cb6882D101d300694918e93F18b52327AA95302] = 2000000;
  }

  function unlock() external {
    if(now < unlockDate) throw;
    uint256 entitled = allocations[msg.sender];
    allocations[msg.sender] = 0;
    if(!StandardToken(BAT).transfer(msg.sender, entitled * exponent)) throw;
  }

}