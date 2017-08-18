// Splitter Contract Practice

pragma solidity ^0.4.6;

contract Splitter {
  address     public owner;
  bool        public contractDead;
  
  struct ApplicantStruct {
    uint    authorizedAmountToWithdrawal;
    bool    isAuthorized;
  }
  
  mapping(address => ApplicantStruct) public applicantsStruct;
  
  event LogDataOfTransaction(address addressOfSender, uint amountDeposited, uint amountRefund);
  event LogDataOfWithdrawal(address addressOfAplicant, uint amountWithdrawn);
  
  function Splitter()
  {
    // Just to know who deploy the contract in the future
    owner = msg.sender;
  }
  
  function isAuthorized(address requestingAddress) 
    public constant 
    returns(bool authorizedParticipant) 
  {
    return applicantsStruct[requestingAddress].isAuthorized;
  }
  
  function depositFunds(address authorizedApplicantAddress1, address authorizedApplicantAddress2) 
    public payable
    returns(bool successTransaction) 
  {
    if(contractDead) throw;
    if(msg.value == 0) throw;
    
    uint totalAmountDeposited = msg.value;
    uint depositRemainder = totalAmountDeposited % 2;
    
    if (depositRemainder % 2 == 1)  {
      if(!msg.sender.send(depositRemainder)) throw;
      totalAmountDeposited = totalAmountDeposited - depositRemainder;
    }
    
    uint amountAuthorizedForApplicant = totalAmountDeposited / 2;
    applicantsStruct[authorizedApplicantAddress1].authorizedAmountToWithdrawal += amountAuthorizedForApplicant;
    applicantsStruct[authorizedApplicantAddress1].isAuthorized = true;
    applicantsStruct[authorizedApplicantAddress2].authorizedAmountToWithdrawal += amountAuthorizedForApplicant;
    applicantsStruct[authorizedApplicantAddress2].isAuthorized = true;
    
    LogDataOfTransaction(msg.sender, totalAmountDeposited, depositRemainder);
    return true;
  }
  
  function withdrawFunds() 
    public
    returns(bool successWithdrawal) 
  {
    if(contractDead) throw;
    if(!isAuthorized(msg.sender)) throw;
    
    uint authorizedAmountToWithdrawal = applicantsStruct[msg.sender].authorizedAmountToWithdrawal;
    applicantsStruct[msg.sender].authorizedAmountToWithdrawal = 0;

    if(!msg.sender.send(authorizedAmountToWithdrawal)) throw;
    LogDataOfWithdrawal(msg.sender, authorizedAmountToWithdrawal);
    
    return true;
  }
  
  function setContractState(bool stateOfContract)
    public 
    returns(bool isContractAlive)
  {
    if(msg.sender != owner) throw;
    contractDead = stateOfContract;
    return !contractDead;
  }     
}