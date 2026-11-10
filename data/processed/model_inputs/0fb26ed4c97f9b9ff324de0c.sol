contract ModifierEntrancy {
  mapping (address => uint) public tokenBalance;
  string constant name = "Nu Token";

                                                                                
                              
  function airDrop() hasNoBalance supportsToken  public{
    tokenBalance[msg.sender] += 20;
  }

                                                     
  modifier supportsToken() {
    require(keccak256(abi.encodePacked("Nu Token")) == Bank(msg.sender).supportsToken());
    _;
  }
                                             
  modifier hasNoBalance {
      require(tokenBalance[msg.sender] == 0);
      _;
  }
}