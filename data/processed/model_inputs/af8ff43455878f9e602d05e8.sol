contract payrollSystem{
    
    address company;
    
    struct employee {
        bool active;
        bool paid;
        uint salary;
        uint balance;
    }
    
    event Transfer(address indexed from, address indexed to,uint amount);
    
    mapping(address => employee) employeeMapper; 
    address[] employeeList;
    
                                 
    function payrollSystem(){
        company = msg.sender;
    }
    
                                                            
    modifier onlyCompany(){
       if(msg.sender != company){
           revert();
       }
        _;
    }
    
                                                           
    function addEmployee(address newEmployee, uint salary) onlyCompany{
        var _employee = employeeMapper[newEmployee];
        _employee.active = true;
        _employee.salary = salary;
        _employee.balance = 0;
        employeeList.push(newEmployee);
    }
    
                                                                                              
    function removeEmployee(address _address) onlyCompany{
        employeeMapper[_address].active = false;
    }
    
                                                                            
    function updateSalary(address _address, uint newSalary) onlyCompany{
        employeeMapper[_address].salary = newSalary;
    }
    
    function listOutEmployees() onlyCompany constant returns(address[]){
        return employeeList;
    }
    
                                                                                                      
    function depositInvestment() onlyCompany payable{
     
    }
    
    function totalSupply() onlyCompany constant returns(uint){
       return this.balance;
    }
    
                                                                   
    function isActive(address check) constant returns(bool){
        return employeeMapper[check].active;
    }
    

                                                       
    function transfer(address _address) private{
       if(employeeMapper[_address].salary < this.balance){
           transferLog(_address);
           employeeMapper[_address].paid = true;
           employeeMapper[_address].balance += employeeMapper[_address].salary;
       }else{
           employeeMapper[_address].paid = false;
       }
    }
    
    function transferLog(address _address) private{
        Transfer(msg.sender,_address,employeeMapper[_address].salary);
    }
    
                                                                                                   
    function sendSalary(address sendTo){
        if(isActive(sendTo) && !employeeMapper[sendTo].paid){
            transfer(sendTo);
        }
    } 
    
    
    function balanceOf(address empAd) public constant returns(uint){
        return employeeMapper[empAd].balance;
    }
    
}