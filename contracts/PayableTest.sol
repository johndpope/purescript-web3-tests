pragma solidity ^0.4.13;


contract PayableTest {
   
    event Content(uint _paidContent);
  
    function seeContent() payable public returns(uint){
        if (msg.value == 1000000000000000000) {
            Content(1);
        } else {
            Content(0);
        }
    }
}