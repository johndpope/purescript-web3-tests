pragma solidity ^0.4.13;

contract ComplexStorage {
    uint public uintVal;
    int public intVal;
    bool public boolVal;
    int224 public int224Val;
    bool[2] public boolVectorVal;
    int[] public intListVal;
    string public stringVal;
    bytes16 public bytes16Val;
    bytes2[4][] public bytes2VectorListVal;

    event ValsSet(uint, int, bool, int224, bool[2], int[], string, bytes16, bytes2[4][]);
    
    function setValues(uint _uintVal, int _intVal, bool _boolVal, int224 _int224Val, bool[2] _boolVectorVal, int[] _intListVal, string _stringVal, bytes16 _bytes16Val, bytes2[4][] _bytes2VectorListVal) {
         uintVal =           _uintVal;
         intVal =            _intVal;
         boolVal =           _boolVal;
         int224Val =         _int224Val;
         boolVectorVal =     _boolVectorVal;
         intListVal =        _intListVal;
         stringVal   =       _stringVal;
         bytes16Val   =      _bytes16Val;
         bytes2VectorListVal = _bytes2VectorListVal;
         
         ValsSet(_uintVal, _intVal, _boolVal, _int224Val, _boolVectorVal, _intListVal, _stringVal, _bytes16Val, _bytes2VectorListVal);
    }
    
}
  
