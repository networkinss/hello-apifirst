#!/bin/bash
pip install fastapi-code-generator
fastapi-codegen --input openapi.yaml --output app/
cp requirements.txt app/
cp log.ini app/
cd app/ || exit 1
python -m venv env
source env/bin/activate
pip install -r requirements.txt




