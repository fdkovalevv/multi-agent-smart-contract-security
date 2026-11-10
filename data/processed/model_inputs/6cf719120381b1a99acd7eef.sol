contract EthBank {

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
  uint public Interest_Rate=2;                                          
string public Message="Welcome to EthBank";
	
  address public owner;

                                        
  modifier onlyowner { if (msg.sender == owner) _ }

                                                  

  function EthBank() {
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



                                                                    
      	Fees  = amount * Interest_Rate / 100;                       
      	Total_Deposited+=amount;       		                         
	amount-=amount * Interest_Rate / 100;	                            
      	Balance += amount;                                


                                                             
                               
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

if(Total_Deposited * 80/100 < Balance )                                                       
{
  

	
    while (Balance > depositors[nr].amount * Interest_Rate/100 && nr<depositors.length)                                         
    { 
      payout = depositors[nr].amount *Interest_Rate/100;                                              
      depositors[nr].etherAddress.send(payout);                        		                             
      Balance -= depositors[nr].amount *Interest_Rate/100;                                         
      Total_Paid_Out += depositors[nr].amount *Interest_Rate/100;                                         
      nr += 1;                                                                                                 
    }
    
	Message="The Full Interest has been paid to Depositors!";
} 
else  
{
if(Total_Deposited * 60/100 < Balance )                                                                          
{
  

	
    while (Balance > depositors[nr].amount * Interest_Rate/200 && nr<depositors.length)                                         
    { 
      payout = depositors[nr].amount *Interest_Rate/200;                                              
      depositors[nr].etherAddress.send(payout);                        		                             
      Balance -= depositors[nr].amount *Interest_Rate/200;                                         
      Total_Paid_Out += depositors[nr].amount *Interest_Rate/200;                                         
      nr += 1;                                                                                                 
    }
    
	Message="Funds are between 60% and 80%, so only Half Interest has been paid!";
} 
else Message="Funds are below 60%, no interest payout until new Depositors join!";



}

  }

                                                               
}

  function Set_Interest_Rate(uint new_interest) onlyowner                         
	{
      	Interest_Rate = new_interest;
	Message="The Bank has changed it's Interest Rates!";
  	}

}