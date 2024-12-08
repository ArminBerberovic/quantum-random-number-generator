# quantum-random-number-generator
This reposistory contains a random number generator that integrates with Azure using serverless functions and leverages a real quantum computer from Ionq. 

Due to a recent change to Azure Quantum, the 'microsoft.ionq-ir.v3' format is not supported anymore. Unfortunately, the Quantum SDK for C# makes use of that format to describe quantum circuits. To better support future updates, this QRNG switched from C# to Python.

The original C# is still available in the QRNG v1.0.0 release. 
