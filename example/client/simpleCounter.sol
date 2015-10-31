contract SimpleCounter {

  uint public storedData;

  event onIncrement(uint count);

  function SimpleCounter() {
    storedData = 0;
  }

  function increment() {
    storedData = storedData + 1;
    onIncrement(storedData);
  }

  function get() constant returns (uint) {
    return storedData;
  }

}
