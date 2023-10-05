#calculate hash

Function Calculate-File-Hash($filepath){

$filehash = Get-FileHash -Path $filepath -Algorithm SHA512
return $filehash
}

Function Erase-Baseline-If-Already-Exists(){

$baselineExists = Test-Path -Path  C:\Users\D\Documents\folder\Baseline.txt


if($baselineExists){

#Delete Baseline

Remove-Item -Path  C:\Users\D\Documents\folder\Baseline.txt


}

}
Write-Host ""
Write-Host "What would you like to do?"
Write-Host "A) Collect new Baseline?"
Write-Host "B) Begin monitoring files with saved BaseLine?"
Write-Host ""

$response = Read-Host -Prompt "Please enter 'A' or 'B'"

Write-Host ""









if ( $response -eq "A".ToUpper())  {
Erase-Baseline-If-Already-Exists

#calculate hash from the target files and stores it in the baseline.txt#
Write-Host "Calculate Hashes,make new baseline.txt" -ForegroundColor Cyan

# Collect all files in the target folder

 $files = Get-ChildItem -Path  C:\Users\D\Documents\folder
 
 
# Calculate the hash for each file and then write to baseline.txt

foreach ($f in $files){


$hash = Calculate-File-Hash  $f.FullName

"$($hash.Path) | $($hash.Hash)" | Out-File -FilePath .\Baseline.txt -Append
}

} elseif ($response -eq "B".ToUpper()) {


$fileHashDictionary  = @{}
#load files hash form baseline and stores the in the dictionary


$filePathsAndHashes = Get-Content -Path  C:\Users\D\Documents\folder\Baseline.txt

foreach ($f in $filePathsAndHashes){

$fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])

 }

 while ($true){

 Start-Sleep -Seconds 1 

 $files = Get-ChildItem -Path C:\Users\D\Documents\folder



 foreach($f in $files)
{

 $hash = Calculate-File-Hash  $f.FullName

 if ($fileHashDictionary[$hash.Path] -eq $null){
 # a new file has been ceated

 Write-Host " $($hash.Path) has been created!" -ForegroundColor Green
 
 }else 
 
 {
 #notify if a file has been chnaged
 if ($fileHashDictionary[$hash.Path] -eq $hash.Hash){
 
 
 
 } else {


Write-Host "$($hash.Path) has changed!!" -ForegroundColor Yellow

 }



}


 #Write-Host "Checking if files match..."
 }

foreach ($key in $fileHashDictionary.Keys) {
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists) {
                # One of the baseline files must have been deleted, notify the user
                Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed -BackgroundColor Gray
            }
        }
        }




}
