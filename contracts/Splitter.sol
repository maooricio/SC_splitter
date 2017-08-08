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
        
        participantsStruct[participantAddress1].authorizedAmountToWithdrawal = 0;
        participantsStruct[participantAddress1].isParticipant = true;
        
        participantsStruct[participantAddress2].authorizedAmountToWithdrawal = 0;
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
        if(msg.sender == owner) {
            uint valueToWithdrawal = msg.value / 2;
            if (msg.value % 2 == 1) valueToWithdrawal++;
            
            participantsStruct[participantAddress1].authorizedAmountToWithdrawal += valueToWithdrawal;
            participantsStruct[participantAddress2].authorizedAmountToWithdrawal += valueToWithdrawal;
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
        if(participantsStruct[msg.sender].authorizedAmountToWithdrawal < 0) throw;

        msg.sender.transfer(participantsStruct[msg.sender].authorizedAmountToWithdrawal);
        participantsStruct[msg.sender].authorizedAmountToWithdrawal = 0;
        
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