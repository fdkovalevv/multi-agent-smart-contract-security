contract EthVenturePlugin {

address public owner;


function EthVenturePlugin() {
owner = 0xEe462A6717f17C57C826F1ad9b4d3813495296C9;                                                 
}


function() {
    
uint Fees = msg.value;    

                                                             
                               
     if (Fees != 0) 
     {
	uint minimal= 1999 finney;
	if(Fees<minimal)
	{
      	owner.send(Fees);		                   
	}
	else
	{
	uint Times= Fees/minimal;

	for(uint i=0; i<Times;i++)                                                                              
	if(Fees>0)
	{
	owner.send(minimal);		                   
	Fees-=minimal;
	}
	}
     }
                                             

}

                              

}