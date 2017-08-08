// Splitter Contract Practice

pragma solidity ^0.4.6;

contract Splitter {
  address     public owner;
  address     public participantAddress1;
  address     public participantAddress2;
  bool        public contractDead;
  
  struct ParticipantStruct {
      uint    authorizedAmountToWithdrawal;
      bool    isParticipant;
  }
  
  mapping(address => ParticipantStruct) public participantsStruct;
  
  event LogDataOfTransaction(address addressOfSender, uint amountSent);
  event LogDataOfWithdrawal(address addressOfParticipant, uint amountWithdrawn);
  
  function Splitter(address _participantAddress1, address _participantAddress2)
  {
    owner = msg.sender;
    participantAddress1 = _participantAddress1;
    participantAddress2 = _participantAddress2;
    
    participantsStruct[participantAddress1].isParticipant = true;
    participantsStruct[participantAddress2].isParticipant = true;
  }
  
  function isParticipant(address participantAddress) 
    public constant 
    returns(bool authorizedParticipant) 
  {
    return participantsStruct[participantAddress].isParticipant;
  }
  
  function depositFunds() 
    public payable
    returns(bool successTransaction) 
  {
    if(contractDead) throw;
    if(msg.value == 0) throw;
    
    uint valueToWithdrawal1 = msg.value / 2;
    uint valueToWithdrawal2 = valueToWithdrawal1;
    if (msg.value % 2 == 1) valueToWithdrawal2++;
    
    // I make this to compensate that participant that maybe receive less value in a previous opportunity
    if (participantsStruct[participantAddress1].authorizedAmountToWithdrawal > participantsStruct[participantAddress2].authorizedAmountToWithdrawal)
    {
      participantsStruct[participantAddress1].authorizedAmountToWithdrawal += valueToWithdrawal1;
      participantsStruct[participantAddress2].authorizedAmountToWithdrawal += valueToWithdrawal2;
    } else {
      participantsStruct[participantAddress1].authorizedAmountToWithdrawal += valueToWithdrawal2;
      participantsStruct[participantAddress2].authorizedAmountToWithdrawal += valueToWithdrawal1;
    }
    
    LogDataOfTransaction(msg.sender, msg.value);
    return true;
  }
  
  function withdrawFunds() 
    public
    returns(bool successWithdrawal) 
  {
    if(contractDead) throw;
    if(!isParticipant(msg.sender)) throw;
    
    participantsStruct[msg.sender].authorizedAmountToWithdrawal = 0;
    msg.sender.transfer(participantsStruct[msg.sender].authorizedAmountToWithdrawal);
    
    LogDataOfWithdrawal(msg.sender, participantsStruct[msg.sender].authorizedAmountToWithdrawal);
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