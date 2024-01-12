RV32I Core Development

Iterative Design and Testbench Steps:
  1.  Fetch - FetchUnit, ExecuteUnit(PC), ControlUnit passing Criteria
      1.  FetchUnit successfully accepts address and returns instruction in FETCH state
      2.  ExecuteUnit successfully increment and loads PC in EXECUTE state
      3.  ControlUnit successfully flows through states