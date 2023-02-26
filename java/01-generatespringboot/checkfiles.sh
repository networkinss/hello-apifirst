#!/bin/bash
if [ ! -f bin/openapi-generator-cli-6.2.1.jar ]; then
  wget -P bin/ https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/6.2.1/openapi-generator-cli-6.2.1.jar
else
  echo "Generator ok."
fi

if [ ! -f openapi.yaml ]; then
  wget -O openapi.yaml https://raw.githubusercontent.com/networkinss/SampleOpenAPICollection/master/petstore/petstore_oas3_inss.yaml
else
  echo "OpenAPI file ok."
fi