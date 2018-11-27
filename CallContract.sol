pragma solidity ^0.4.18;

contract CallContract {
    address client;
    address site;
    address expert;
    uint callID;
    bool expertPaid = false;
    
    event Rating(string message);
    
    constructor(address siteAddress, address expertAddress, uint _callID) public payable {
        client = msg.sender;
        site = siteAddress;
        callID = _callID;
        expert = expertAddress;
    }
    
    modifier ifSite() {
        if(msg.sender != site) {
            revert();
        }
        _;
    }
    
    modifier ifClient() {
        if(msg.sender != client) {
            revert();
        }
        _;
    }
    
     modifier ifExpert() {
        if(msg.sender != expert) {
            revert();
        }
        _;
    }
    
    function releaseExpertFunds(uint amount) public ifSite {
        expert.transfer(amount);
        expertPaid = true;
    }
    
    function releaseSiteFunds() public ifSite {
        if(!expertPaid) return revert();
        site.transfer(getAmount());
    }
    
    function withdrawFunds() public ifSite {
        if(expertPaid) return revert();
        client.transfer(address(this).balance);
    }
    
    function getAmount() public constant returns(uint) {
        return address(this).balance;
    }
    
    function getSiteAddress() public constant returns(address) {
        return site;
    }
    
    function getCallId() public constant returns(uint) {
        return callID;
    }
    
    function expertReview(string message) public ifExpert {
        emit Rating(message);
    }
    
    function clientReview(string message) public ifClient {
        emit Rating(message);
    }
}
