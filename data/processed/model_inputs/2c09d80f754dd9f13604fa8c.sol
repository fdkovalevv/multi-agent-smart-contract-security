contract BaseRegistry {

                                  
    address owner;

                                               
    struct Record {
                                                    
        address owner;
                                                       
        uint time;
                                                            
        uint keysIndex;
    }

                                                       
    mapping(address => Record) records;

                                                           
    uint public numRecords;

                                                        
    address[] private keys;



                  
    function BaseRegistry() {
        owner = msg.sender;
    }

                                                           
    function register(address key) {
        if (records[key].time == 0) {
            records[key].time = now;
            records[key].owner = msg.sender;
            records[key].keysIndex = keys.length;
            keys.length++;
            keys[keys.length - 1] = key;
            numRecords++;
        } else {
            returnValue();
        }
    }

                                              
    function update(address key) {
                                                
        if (records[key].owner == msg.sender) {}
    }

                                
    function unregister(address key) {
        if (records[key].owner == msg.sender) {
            uint keysIndex = records[key].keysIndex;
            delete records[key];
            numRecords--;
            keys[keysIndex] = keys[keys.length - 1];
            records[keys[keysIndex]].keysIndex = keysIndex;
            keys.length--;
        }
    }

                                            
    function transfer(address key, address newOwner) {
        if (records[key].owner == msg.sender) {
            records[key].owner = newOwner;
        } else {
            returnValue();
        }
    }

                                               
    function isRegistered(address key) returns(bool) {
        return records[key].time != 0;
    }

    function getRecordAtIndex(uint rindex) returns(address key, address owner, uint time) {
        Record record = records[keys[rindex]];
        key = keys[rindex];
        owner = record.owner;
        time = record.time;

    }

    function getRecord(address key) returns(address owner, uint time) {
        Record record = records[key];
        owner = record.owner;
        time = record.time;

    }

                                                                         
                                                                              
                    
    function getOwner(address key) returns(address) {
        return records[key].owner;
    }

                                                                             
                                                                                    
                    
    function getTime(address key) returns(uint) {
        return records[key].time;
    }

                                                            
    function getTotalRecords() returns(uint) {
        return numRecords;
    }

                                                                          
                                                                    
    function returnValue() internal {
        if (msg.value > 0) {
            msg.sender.send(msg.value);
        }
    }

                                                                          
                    
    function withdraw(address to, uint value) {
        if (msg.sender == owner) {
            to.send(value);
        }
    }

    function kill() {
        if (msg.sender == owner) {
            suicide(owner);
        }
    }
}

contract test2 is BaseRegistry {}