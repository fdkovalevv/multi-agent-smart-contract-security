contract RSALib{
    
    modifier onlyBy(address authorized){
        if (msg.sender == authorized){
            _;
        }
        else{
            throw;
        }
    }
    function mod(int a, int n) returns (int){
       return a - n*(a/n);
    }
     
    function discretePower(int m, int d, int n) returns (int){
       int refM = m;
       int refD = d-1;
       while (refD != 0){
           if(mod(d,2) == 0){
               refM = mod(refM*refM,n);
               refD /= 2;
           }
           else{
               refM = mod(refM*m,n);
               refD -- ;
           }
        }
        return refM;
    }
 
    function bezout(int a, int b)returns(int, int,int){
       int rA=a;
       int rB=b;
       int uA = 1;
       int vA = 0;
       int uB = 0;
       int vB = 1;
                     
                  
                  
        
            
                  
                  
          
       while (rB != 0){
           int q = rA/rB;
           (rA, uA, vA, rB, uB, vB) = (rB, uB, vB, rA - q *rB, uA - q*uB, vA - q*vB);
       }
       return (rA,uA,vA);
    }
}

contract LocalB is RSALib{
    int message;
bool succeed;
bool fail;
    
    function LocalB(int _message){
        message = _message;
    }
    
    function sendChallengeTo(address _iDContract){
        IDCaseD iDContract = IDCaseD(_iDContract);
        iDContract.sendChallenge(discretePower(message, iDContract.publicRSAPower(), iDContract.publicRSAModule()));
    }
    
    function checkSol(address _iDContract)returns(bool){
        IDCaseD iDContract = IDCaseD(_iDContract);
        if (message == iDContract.solution(this)){
            succeed =  true;
        }
        else{
            fail = true;
        }
    }
}