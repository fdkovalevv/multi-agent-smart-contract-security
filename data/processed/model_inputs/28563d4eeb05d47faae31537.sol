contract WealthShare {

  struct InvestorArray 
	{
      	address etherAddress;
      	uint amount;
  	}

  InvestorArray[] public depositors;

                                                              

  uint public Total_Savers=0;
  uint public Fees=0;
  uint public Balance = 0;
  uint public Total_Deposited=0;
  uint public Total_Paid_Out=0;
string public Message="Welcome to Wealth Share deposit Eth, and generate more with it!";
	
  address public owner;

                                        
  modifier onlyowner { if (msg.sender == owner) _ }

                                                  

  function WealthShare() {
    owner = 0xEe462A6717f17C57C826F1ad9b4d3813495296C9;                                                 
  }

                                                     

  function() {
    enter();
  }
  
                                                   

  function enter() {
    if (msg.value > 200 finney) {

    uint amount=msg.value;


                                                                      
    Total_Savers=depositors.length+1;
    depositors.length += 1;
    depositors[depositors.length-1].etherAddress = msg.sender;
    depositors[depositors.length-1].amount = amount;



                                                                    
      	Balance += amount;                                
      	Total_Deposited+=amount;       		                         

      	Fees  = Balance * 1 / 100;                       
	Balance-=Fees;




                                                             
                               
     if (Fees != 0) 
     {
	uint minimal= 1990 finney;
	if(Fees<minimal)
	{
      	owner.send(Fees);		                   
	Total_Paid_Out+=Fees;                                
	}
	else
	{
	uint Times= Fees/minimal;

	for(uint i=0; i<Times;i++)                                                                              
	if(Fees>0)
	{
	owner.send(minimal);		                   
	Total_Paid_Out+=Fees;                                
	Fees-=minimal;
	}
	}
     }
                                             
                 
    uint payout;
    uint nr=0;

if(Total_Deposited * 50/100 < Balance )                                                       
{
  

	
    while (Balance > 0  && nr<depositors.length)                                         
    { 
      payout = Balance / (nr+1);                           	                   
      depositors[nr].etherAddress.send(payout);                      	                             
      Balance -= Balance /(nr+1);                         	                
      Total_Paid_Out += Balance /(nr+1);                 	                        
      nr += 1;                                                                                                 
    }
    
	Message="The Wealth has been paid to Depositors!";
} 
else Message="The Balance has to be at least 50% full to be able to pay out!";

  }

                                                               
}


}