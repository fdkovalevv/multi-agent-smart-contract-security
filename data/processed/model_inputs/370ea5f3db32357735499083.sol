contract BaseCertoChainContract {
    address creator; 
    function BaseCertoChainContract() public    {   creator = msg.sender;   }
    
    modifier onlyBy(address _account)
    {
        if (msg.sender != _account)
            throw;
        _;
    }
    
    function kill() onlyBy(creator)
    {               suicide(creator);     }
     
     function setCreator(address _creator)  onlyBy(creator)
    {           creator = _creator;     }
  
}

contract DocumentCertoChainContract   is BaseCertoChainContract    
{  
    string  public  Emitter;                    
    string  public  Name;                  
    string  public  Description ;              
    string  public  FileName;                     
    string  public  FileHash;                   
    string  public  FileData;                   
    string  public  Notes ;
    address public  Revision; 
    
    function   DocumentCertoChainContract() public
    {
        Revision=address(this);
    }
    
    function setData(string _Emitter,string _Name,string _Description, string _FileName,string _FileHash,string _FileData)  onlyBy(creator)
    {
          Emitter=_Emitter;
          Name=_Name;
          Description=_Description;
          FileName=_FileName;
          FileHash=_FileHash;
          FileData=_FileData;
       
    }
    
     
    
    function setRevision(address _Revision)  onlyBy(creator)
    {
          Revision = _Revision;
        
    }
     
     
    function setNotes(string _Notes)  onlyBy(creator)
    {
         Notes =  _Notes;
         
    }
}