namespace QuantumLibrary {
  open Microsoft.Quantum.Diagnostics;
  open Microsoft.Quantum.Intrinsic;
  open Microsoft.Quantum.Measurement;
  open Microsoft.Quantum.Canon;
 
  @EntryPoint()
  operation GenerateRandomBits(n : Int) : Result[] {
    use qubits = Qubit[n];
    ApplyToEach(H, qubits);
    let results = MeasureEachZ(qubits);
    ResetAll(qubits);
	  return results;
  }
}
 
