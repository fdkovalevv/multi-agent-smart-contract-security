contract SimpleMathTest003 {
    
    uint calculationFee = 0.001 ether;

  modifier payForResults() {
      require(msg.value == calculationFee);
    _;
  }
  

  function add(uint a, uint b) public payForResults payable returns(uint) {
    uint c = a + b;
    return c;
  }
  
  function mul(uint a, uint b) public pure returns (uint) {
    uint c = a * b;
    return c;
  }
  
  function div(uint a, uint b) public pure returns(uint) {
    uint c = a / b;
    return c;
                                                 
  }
  
  function sub(uint a, uint b) public pure returns(uint) {
    uint c = a - b;
    return c;
                                                       
  }

}