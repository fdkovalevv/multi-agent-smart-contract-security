contract Proxy {
  address public owner;

  constructor() public payable{
    owner = msg.sender;  
    require(msg.value > 0);
  }

  function forward(address callee, bytes calldata data) external {
                                                                                                                                                                                                                                                                                                                                                                                        
    callee.delegatecall(data);
  }
  
  function withdraw() external{
      require(msg.sender == owner);
      msg.sender.transfer(address(this).balance);
  }

}