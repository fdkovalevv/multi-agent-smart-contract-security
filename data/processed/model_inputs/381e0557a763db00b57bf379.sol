contract HelloWorld {  
    event log_string(bytes32 log);         

    function () {                     
        log_string("Hello World!");
    }
}