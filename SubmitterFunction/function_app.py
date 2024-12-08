import azure.functions as func
import qsharp
import os
import azure.quantum
from azure.identity import ManagedIdentityCredential

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="generateRandomBits")
def generateRandomBits(req: func.HttpRequest) -> func.HttpResponse:
    
    # get length of the random number from POST body
    req_body = req.get_json()
    numberlength = req_body.get("randomNumberLength")

    # init Q# project 
    qsharp.init(project_root='.', target_profile=qsharp.TargetProfile.Base)

    # compile Q# code
    MyProgram = qsharp.compile(f"QuantumLibrary.GenerateRandomBits({numberlength})")

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
    
    # specify target
    MyTarget = workspace.get_targets(os.environ['target'])

    # submit job
    job = MyTarget.submit(MyProgram, "RandomNumberCreation", shots=500)

    return func.HttpResponse(f"Hello, the job-id is: {job.id}")