contract Manageable {

	uint public mangerCount;
	mapping (address=>bool)public managers;
	                                           
	                   
	
	modifier onlyManager
	{
	                              
	    _;
	}
	
	
	event ManagerChanged(uint _state,address _address,uint _managerCount);
	
	
	function Manageable() public   {
		                                                      
	    managers[msg.sender] = true;
		mangerCount++;
                                             
		                  
	}
	
	
	
	function canAccess() internal  returns (bool ) {
		 
		
		                                                  
		return managers[msg.sender];
		                  
	}
	
	
	
	function addManager(address _newManagerAddress) public  onlyManager  {
		 
		
		                                                           
		if(!managers[_newManagerAddress]){
			mangerCount++;
			ManagerChanged(0,_newManagerAddress,mangerCount);	
		}
		
		managers[_newManagerAddress] = true;
		                  
	}
	
	
	
	function removeManager(address _managerAddress) public  onlyManager  {
		 
		
		                                                              
		if(managers[_managerAddress]){
			mangerCount--;
			ManagerChanged(1,_managerAddress,mangerCount);
		}
		managers[_managerAddress] = false;
		                  
	}
	
	
	
	function isManager(address _managerAddress) public   constant returns (bool ) {
		                                                          
		if( managers[_managerAddress])
			return true;
		
		return false;
		                  
	}
	
	                                           
	                 
	                   
}

contract BlogRegistry is Manageable {

	uint public blogCount;
	mapping (uint=>ShortBlog)public blogs;
	                                             
	                 
	                   
	
	
	event NewBlog(uint index,string name,address blogAddress);
	
	
	  
                                
                               
   
                               
          
     
   
	function registerBlog(string _name) public  onlyManager() returns (ShortBlog ) {
		
		                                                              
		ShortBlog sb = new ShortBlog(_name);
		sb.addManager(msg.sender);
		blogs[blogCount] = sb;
		NewBlog(blogCount,_name,sb);
		blogCount++;
		return sb; 
		                  
	}
	
	                                             
	                 
	                   
}