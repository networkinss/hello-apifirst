$generatorExists = Test-Path -Path "bin/openapi-generator-cli-6.2.1.jar"
New-Item -Path bin -ItemType Directory -ErrorAction Ignore
if (!$generatorExists) {
    Invoke-WebRequest -Uri "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/6.2.1/openapi-generator-cli-6.2.1.jar" -OutFile "bin/openapi-generator-cli-6.2.1.jar"
}else{
    Write-Host "Generator file ok."
}


$openapiExists = Test-Path -Path "openapi.yaml"
if (!$openapiExists) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/networkinss/SampleOpenAPICollection/master/petstore/petstore_oas3_inss.yaml" -OutFile "openapi.yaml"
}else{
    Write-Host "OpenAPI file ok."
}
