contract TestQuery{
  struct Details{
    uint amount;
    address owner;
    uint transferId;
  }

  uint transNonce;
    event Locked(address _from, uint _value);

  mapping(uint => Details) transferDetails;                                 
    mapping(address => uint[]) transferList;                                         

  function lockforTransfer() payable public returns(uint){
    require(msg.value > 0);
        transNonce += 1;
    transferDetails[transNonce] = Details({
      amount:msg.value,
      owner:msg.sender,
      transferId:transNonce
      });
    transferList[msg.sender].push(transNonce);
    return(transNonce);
  }

  function getTransfer(uint _transferId) public view returns(uint,address,uint){
    Details memory _locked = transferDetails[_transferId];
    return(_locked.amount,_locked.owner,_locked.transferId);
  }

}