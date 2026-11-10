contract TransferMoney {

  mapping (address => uint) bankAccountMoney;

           
  function contractMoneyBalance() constant public returns(uint){
    return this.balance;
  }

           
  function addressMoneyBalance() constant public returns(uint){
    return bankAccountMoney[msg.sender];
  }



          
  function depositMoney(string message) payable public{
    require(msg.value >= 0);

    if (bankAccountMoney[msg.sender] == 0) {
            
      bankAccountMoney[msg.sender] = msg.value;
    } else {
      bankAccountMoney[msg.sender] = bankAccountMoney[msg.sender] + msg.value;
    }

  }


  



}