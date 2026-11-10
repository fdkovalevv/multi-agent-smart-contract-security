contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

contract coinScheduleReferral is SafeMath {
    
    uint256 public weiRaised = 0;                                                                    
    address public wwamICOcontractAddress = 0x59a048d31d72b98dfb10f91a8905aecda7639f13;
    address public pricingStrategyAddress = 0xe4b9b539f047f08991a231cc1b01eb0fa1849946;
    address public tokenAddress = 0xf13f1023cfD796FF7909e770a8DDB12d33CADC08;

    function() payable {
        wwamICOcontractAddress.call.gas(300000).value(msg.value)();
        weiRaised = safeAdd(weiRaised, msg.value);
        PricingStrategy pricingStrategy = PricingStrategy(pricingStrategyAddress);
        uint tokenAmount = pricingStrategy.calculatePrice(msg.value, 0, 0, 0, 0);
        StandardToken token = StandardToken(tokenAddress);
        token.transfer(msg.sender, tokenAmount);
    }
}