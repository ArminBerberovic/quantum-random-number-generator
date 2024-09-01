using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Quantum;
using Azure.Storage.Blobs; 
using Azure.Storage.Blobs.Models;
using Newtonsoft.Json;
using Azure.Identity;

namespace RetrieverFunction
{
    public class RandomNumberRetriever
    {

        [Function("retrieveRandomNumber")]
       public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req)
        {
            // connecting to quantum workspace
            var quantumworkspace = new Workspace(
                subscriptionId: Environment.GetEnvironmentVariable("subscriptionId"),
                resourceGroupName: Environment.GetEnvironmentVariable("resourceGroupName"),
                workspaceName: Environment.GetEnvironmentVariable("workspaceName"),
                location: Environment.GetEnvironmentVariable("location"));

            // read jobID from query
            string jobID = req.Query["jobId"];
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            jobID = data?.jobId;

            // get Job status
            var job = quantumworkspace.GetJob(jobID);
            var status = job.Details.Status;
            
             if (job.Succeeded){
                
                // connect to Storage Account
                var storageAccountName = Environment.GetEnvironmentVariable("quantumStorageAccount");
                var blobServiceClient = new BlobServiceClient(new Uri($"https://{storageAccountName}.blob.core.windows.net"), 
                new ManagedIdentityCredential());

                // get blob content
                var containerName = $"quantum-job-{jobID}"; 
                var containerClient = blobServiceClient.GetBlobContainerClient(containerName);
                var blobClient = containerClient.GetBlobClient("rawOutputData"); 
                BlobDownloadResult downloadResult = await blobClient.DownloadContentAsync();
                string blobContents = downloadResult.Content.ToString();

                // format blob content
                var result = JsonConvert.DeserializeObject<Dictionary<string, Dictionary<string, double>>>(blobContents)["histogram"];
                var highestProbabilityNumber = result.OrderByDescending(kv => kv.Value).First();

                return new OkObjectResult($"Hey, this is your result [randomNumber,probability]: {highestProbabilityNumber} ");

             }
            return new OkObjectResult("Job not ready yet!");
           
        }
    }
}

