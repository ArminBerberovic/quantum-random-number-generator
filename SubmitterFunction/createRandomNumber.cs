	using Microsoft.AspNetCore.Http;
	using Microsoft.AspNetCore.Mvc;
	using Microsoft.Azure.Functions.Worker;
	using Newtonsoft.Json;
	using Microsoft.Azure.Quantum;
	using Microsoft.Quantum.Providers.IonQ.Targets;
	using QuantumLibrary;

	namespace SubmitterFunction
	{
		public class RandomNumberGenerator
		{
			[Function("createRandomNumber")]
			public static async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req)
			{
				// read randomNumberLength from query
				string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
				dynamic data = JsonConvert.DeserializeObject(requestBody);
				int randomNumberLength = data?.randomNumberLength;

				// connecting to quantum workspace
				var quantumworkspace = new Workspace(
					subscriptionId: Environment.GetEnvironmentVariable("subscriptionId"),
					resourceGroupName: Environment.GetEnvironmentVariable("resourceGroupName"),
					workspaceName: Environment.GetEnvironmentVariable("workspaceName"),
					location: Environment.GetEnvironmentVariable("location"));	

				// connecting to quantum machine
				var quantumMachine = new IonQQuantumMachine(
					target: Environment.GetEnvironmentVariable("target"),
					workspace: quantumworkspace);   

				// submit circuit to quantum machine
				var randomNumberJob = quantumMachine.SubmitAsync(GenerateRandomBits.Info, randomNumberLength);  

				return new OkObjectResult($"Result: {randomNumberJob.Result.Id}");
			}
		}
	}
