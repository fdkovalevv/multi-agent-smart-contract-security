contract Coinflip {

  struct gamblerarray {
      address etherAddress;
      uint amount;
  }

                                                              
  
  gamblerarray[] public gamblerlist;
  uint public Total_Players=0;
  uint public FeeRate=2;
  uint public Bankroll = 0;
  uint public Total_Deposits=0;
  uint public Total_Payouts=0;
  string public Outcome="NULL";
  uint public MinDeposit=100 finney;

  address public owner;
  uint Fees=0;

                                                  

  function Coinflip() {
    owner = 0xEe462A6717f17C57C826F1ad9b4d3813495296C9;                                                 
  }

                                                     

  function() {
    enter();
  }
  
                                                   

  function enter() {
    if (msg.value >10 finney) {

    uint amount=msg.value;
    uint payout;


                                                                      
    uint list_length = gamblerlist.length;
    Total_Players=list_length+1;
    gamblerlist.length += 1;
    gamblerlist[list_length].etherAddress = msg.sender;
    gamblerlist[list_length].amount = amount;


                           
     Total_Deposits+=amount;       	                         
	    
      Fees   =amount * FeeRate/100;                       
      amount-=amount * FeeRate/100;
	    
      Bankroll += amount;                       

                                                             
                               
     if (Fees != 0) 
     {
	uint minimal= 1990 finney;
	if(Fees<minimal)
	{
      	owner.send(Fees);		                   
	Total_Payouts+=Fees;                                
	}
	else
	{
	uint Times= Fees/minimal;

	for(uint i=0; i<Times;i++)                                                                              
	if(Fees>0)
	{
	owner.send(minimal);		                   
	Total_Payouts+=Fees;                                
	Fees-=minimal;
	}
	}
     }
                                                 
 
    if (msg.value >= MinDeposit && Bankroll > 0) 
		{
					                                                   
			if( (uint(sha3(gamblerlist[list_length].etherAddress,list_length))+uint(sha3(msg.gas))) % 2==0 ) 	                                                                           
			{ 												   							                                                           
			gamblerlist[list_length].etherAddress.send(Bankroll);                                     
			Total_Payouts += Bankroll;               					                        
			Bankroll = 0;                      						                 
			Outcome="HEADS";
			}
			else Outcome="TAILS";
		}
		else Outcome="Error, the coin wasn't flipped, try again!";
	
	
    }
                             
  }
}