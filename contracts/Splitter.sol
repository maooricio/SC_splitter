// Splitter Contract Practice

pragma solidity ^0.4.6;

contract Splitter {
  address      public owner;
  address[2]   public participantsAdresses;
  bool         public participantsEstablished;
  bool         public contractDead;

  event LogParticipantsAdresses(address[2] newParticipantsAddresses);
  event LogAccountsBalances(address participantAddress1, uint balanceParticipant1, address participantAddress2, uint balanceParticipant2);
  
  function Splitter() {
    owner = msg.sender;
  }
  
  function contribute()
    public payable
    returns(bool successTransaction)
  {
    if(contractDead) throw;
    if(msg.value == 0) throw;
    if(msg.sender == owner && !participantsEstablished) throw;
    if(msg.sender == owner) {
      for(uint i = 0; i<2; i++){
        if(!participantsAdresses[i].send(msg.value/2)) throw;
      }
      
      LogAccountsBalances(participantsAdresses[0], participantsAdresses[0].balance, participantsAdresses[1], participantsAdresses[1].balance);
    }
    
    return true;
  }
  
  function seeParticipantsAddresses() constant returns (address[2] actualParticipantAddresses) {
    return participantsAdresses;
  }
  
  function addTwoParticipantsAccounts(address participantAddress1, address participantAddress2) 
    public
    returns(bool participantsAdded) 
  {
    if(contractDead) throw;
    if(msg.sender != owner) throw;
    if(participantAddress1 == 0 || participantAddress2 == 0) throw;
    
    participantsAdresses[0] = participantAddress1;
    participantsAdresses[1] = participantAddress2;
    
    participantsEstablished = true;
    LogParticipantsAdresses(participantsAdresses);
    return true;
  }
  
  function setContractState(bool stateOfContract) public returns(bool isContractAlive) {
    if(msg.sender != owner) throw;
    contractDead = stateOfContract;
    if(contractDead) return false;
    else return !contractDead;
  }
  
  function seeContractState() constant returns (bool actualContractState) {
    return contractDead;
  }
}