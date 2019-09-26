startRSAT.ps1: Powershell Script which monitors an IN folder on any files dropped by MS Flow which instructs RSAT to run a Test Case against D365

Demo Microsoft Flow for running D365 RSAT directly from Azure DevOps. Note: I didn't manage to import this Flow into another tenant than the tenant where the Flow was built - MS Flow complaints about a problem with the authorisation against Azure DevOps - So you may have to amend the packaged json definition of the Flow to allow import.
