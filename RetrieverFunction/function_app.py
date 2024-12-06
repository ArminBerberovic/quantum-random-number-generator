import azure.functions as func
import qsharp
import os
import json
import azure.quantum
from azure.identity import ManagedIdentityCredential
from azure.storage.blob import BlobServiceClient

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="retrieveRandomNumber")
def retrieveRandomNumber(req: func.HttpRequest) -> func.HttpResponse:
    req_body = req.get_json()
    job_id = req_body.get("jobID")
    
    # get managed identity credential
    mgcredential = ManagedIdentityCredential()

    # connect to workspace
    workspace = azure.quantum.Workspace(
        subscription_id = os.environ['subscriptionId'],
        name = os.environ['workspaceName'],
        resource_group = os.environ['resourceGroupName'],
        location = os.environ['location'],
        credential = mgcredential
        )
    
    # retrieve job status 
    job = workspace.get_job(job_id)
    status = job.details.status

    if status == "Succeeded":
        
        # Connect to Storage Account
        storage_account_name = os.environ['quantumStorageAccount']
        blob_service_client = BlobServiceClient(
            account_url=f"https://{storage_account_name}.blob.core.windows.net",
            credential=mgcredential
        )

        # read content from blog
        container_name = f"job-{job_id}"
        container_client = blob_service_client.get_container_client(container_name)
        blob_client = container_client.get_blob_client("outputData")
        blob_content = blob_client.download_blob().content_as_text()

        # parsing the output of the quantum computer
        # to find the measurement with the highest count
        # and return it as the random number
        result = json.loads(blob_content)["Results"][0]["Histogram"]
        highest_count_entry = max(result, key=lambda x: x["Count"])
        number_with_highest_count = highest_count_entry["Outcome"]
        
        return func.HttpResponse(f"Hey, this is your random number in binary encoding: {number_with_highest_count}.")
    else:
        return  func.HttpResponse("Job not ready yet!")

    