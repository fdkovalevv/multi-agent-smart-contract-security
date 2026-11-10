contract EtherUnitConverter {
      
                                        
      
                         
                                                                   
       

    mapping (string => uint) etherUnits;
    
                                                
                                                                           
      
    function EtherUnitConverter () {
        etherUnits['noether']
        = 0;
        etherUnits['wei'] 
        = 10**0;
        etherUnits['kwei'] = etherUnits['babbage'] = etherUnits['femtoether']
        = 10**3;
        etherUnits['mwei'] = etherUnits['lovelace'] = etherUnits['picoether'] 
        = 10**6;
        etherUnits['gwei'] = etherUnits['shannon'] = etherUnits['nanoether'] = etherUnits['nano'] 
        = 10**9;
        etherUnits['szabo'] = etherUnits['microether'] = etherUnits['micro'] 
        = 10**12;
        etherUnits['finney'] = etherUnits['milliether'] = etherUnits['milli'] 
        = 10**15;
        etherUnits['ether'] 
        = 10**18;
        etherUnits['kether'] = etherUnits['grand']
        = 10**21;
        etherUnits['mether'] = 10**24;
        etherUnits['gether'] = 10**27;
        etherUnits['tether'] = 10**30;
    }
    
    function convertToWei(uint amount, string unit) external constant returns (uint) {
        return amount * etherUnits[unit];
    }
    
    function convertTo(uint amount, string unit, string convertTo) external constant returns (uint) {
        uint input = etherUnits[unit];
        uint output = etherUnits[convertTo];
        if(input > output)
            return amount * (input / output);
        else
            return amount / (output / input);
    } 
    
    string[11] unitsArray = ['wei', 'kwei', 'mwei', 'gwei', 'szabo', 'finney', 'ether', 'kether', 'mether', 'gether', 'tether'];

    function convertToEach(uint amount, string unit, uint unitIndex) external constant returns (uint convAmt, string convUnit) {

        uint input = etherUnits[unit];
        uint output = etherUnits[unitsArray[unitIndex]];
            
        if(input > output)
            convAmt = (amount * (input / output));
        else
            convAmt = (amount / (output / input));
        convUnit = unitsArray[unitIndex];
    }
    
    function convertToAllTable(uint amount, string unit) 
    external constant returns 
    (uint weiAmt,
    uint kweiAmt,
    uint mweiAmt,
    uint gweiAmt,
    uint szaboAmt,
    uint finneyAmt,
    uint etherAmt) {
    
        uint input = etherUnits[unit];
                                                                        
        (weiAmt, kweiAmt, mweiAmt, gweiAmt, szaboAmt, finneyAmt, etherAmt) = iterateTable(amount, input);
    }
    
    function iterateTable(uint _amt, uint _input) private constant returns 
    (uint, uint, uint, uint, uint, uint, uint) {
        uint[7] memory c;
        
        for(uint i = 0; i < c.length; i++) {
            uint output = etherUnits[unitsArray[i]];
            
            if(_input > output)
                c[i] = (_amt * (_input / output));
            else
                c[i] = (_amt / (output / _input));
        }
        return (c[0],c[1],c[2],c[3],c[4],c[5],c[6]);
    }
}