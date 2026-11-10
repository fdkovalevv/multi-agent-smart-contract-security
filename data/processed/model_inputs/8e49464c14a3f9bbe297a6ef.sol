contract SecureAuction {
  address currentFrontrunner;
  uint    currentBid;
                                         
  mapping(address => uint) refunds;

                                                                  
  function bid() payable external {
    require(msg.value > currentBid);

    if (currentFrontrunner != 0) {
      refunds[currentFrontrunner] += currentBid;
    }

    currentFrontrunner = msg.sender;
    currentBid         = msg.value;
  }

                                                 
  function withdraw() external {
                                                       
                             
    uint refund = refunds[msg.sender];
    refunds[msg.sender] = 0;

    msg.sender.send(refund);
  }
}