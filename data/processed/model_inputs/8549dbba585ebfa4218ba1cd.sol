contract IterLog        
{
    address creator; 
    
    byte   public DateYY;
    byte   public DateMM;
    byte   public DateDD;
    string public Message;   
    string public DocUri;
    bytes32 public DocSHA3;    
    address public NextLog;
    address public PrecLog;


    event InitLog(address indexed _sender,  uint256 _time,byte _DateYY,byte _DateMM,byte _DateDD,string _Message, bytes32  _DocSHA3,address _NextLog ,address _PrecLog);

    function IterLog() public   
    {
        creator = msg.sender;
                             
        PrecLog=address(this);
        NextLog=address(this);
        
      
    }

    function Init(byte _DateYY,byte _DateMM,byte _DateDD,string _Message, 
                     
    bytes32  _DocSHA3,
    address _NextLog,
    address _PrecLog
    ) public   
    {
       
    DateYY    = _DateYY;
    DateMM    = _DateMM;
    DateDD    = _DateDD;
    
    
    Message = _Message;
                     
    DocSHA3=  _DocSHA3;
                         
    
    NextLog=_NextLog;
    PrecLog=_PrecLog;
                         
    InitLog(msg.sender,now,_DateYY,_DateMM,_DateDD,_Message,_DocSHA3,_NextLog ,_PrecLog);
        
    }

    function setMessage(string _Message)  onlyBy(creator)
    {
          Message = _Message;
                                 
    }
    
     
      function setDate(byte _DateYY,byte _DateMM,byte _DateDD)  onlyBy(creator)
    {
          DateYY = _DateYY;
          DateMM = _DateMM;
          DateDD = _DateDD;
          
                                 
    }
    
    
    
       function setDocUri(string _DocUri)  onlyBy(creator)
    {
          DocUri = _DocUri;
                                 
    }
    
     
       function setDocSHA3(bytes32  _DocSHA3)  onlyBy(creator)
    {
          DocSHA3 = _DocSHA3;
                               
    }
    
       
     function setNextLog(address _NextLog)  onlyBy(creator)
    {
          NextLog = _NextLog;
                                 
    }
    
   
        
      function setPrecLog(address _PrecLog)  onlyBy(creator)
    {
         PrecLog = _PrecLog;
                             
    }


  function appendTo(address _PrecLog)  onlyBy(creator) 
    {
        PrecLog = _PrecLog;
        IterLog  p  = IterLog(_PrecLog);
     
        p.setNextLog(address(this));
        
        
         
                             
    }

 



   modifier onlyBy(address _account)
    {
        if (msg.sender != _account)
            throw;
        _;
    }
    
    
     function kill() onlyBy(creator)
    {    
            suicide(creator);                                                                  
    }
    
    
     function setCreator(address _creator)  onlyBy(creator)
    {
          creator = _creator;
    }
    
    
    
    
}