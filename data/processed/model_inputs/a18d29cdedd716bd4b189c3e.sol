contract TestRegistry {

  mapping(address => uint) public registry;

  function register(uint x) payable public {
    registry[msg.sender] = x;
  }

}