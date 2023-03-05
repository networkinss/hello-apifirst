# fastapi-code-generator

This code generator creates a FastAPI app from an openapi file.  
The generator is used from [fastapi-code-generator Git repository](https://github.com/koxudaxi/fastapi-code-generator).
The description here is partly from that repository.  
I added some more information to make it easier to get started with the generated code.  
After all, the generated code is not ready to run and needs some adjustments.  
However, I think it is useful to have a starting point for a FastAPI app.

There is a Postman collection in the ./resources folder to check the API endpoints.

## The project is in experimental phase.

fastapi-code-generator uses [datamodel-code-generator](https://github.com/koxudaxi/datamodel-code-generator) to generate pydantic models

## Help
See [documentation](https://koxudaxi.github.io/fastapi-code-generator) for more details.


## Installation

To install `fastapi-code-generator`:
```sh
$ pip install fastapi-code-generator
```

## Usage

The `fastapi-code-generator` command:
```
Usage: fastapi-codegen [OPTIONS]

Options:
  -i, --input FILENAME     [required]
  -o, --output PATH        [required]
  -t, --template-dir PATH
  -m, --model-file         Specify generated model file path + name, if not default to models.py
  -c, --custom-visitors    PATH - A custom visitor that adds variables to the template.
  --install-completion     Install completion for the current shell.
  --show-completion        Show completion for the current shell, to copy it
                           or customize the installation.

  --help                   Show this message and exit.
```

## Example
### OpenAPI
```sh
$ fastapi-codegen --input openapi.yaml --output app/
```
or use the script
```sh
$ ./generate.sh
```
This script will also generate a virtual environment and install the dependencies.

### Adjustments
It is not ready to run yet, though. A few adjustments are needed.  

**To make it run**, you need to add following code to the bottom of the main.py file:
```python 
if __name__ == "__main__":
    cwd = pathlib.Path(__file__).parent.resolve()
    print("cwd: " + str(cwd))
    alive = get_db_isalive()
    if alive:
        print("MongoDB server connection is alive.")
        uvicorn.run(app, host="127.0.0.1", port=8000, log_config=f"{cwd}/log.ini")
    else:
        print("MongoDB server is not alive.")
        print("Server not started because of missing DB connection")
```
And add the related imports:
```python
from starlette.middleware.cors import CORSMiddleware
import pathlib
import uvicorn
```

Add this (optional) code to the top (after the variable 'app'):
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"appstatus": "up"}
```
It just ensures that the app answers to the root path: '/'.  


In the upload_file method you need to change the order of the parameter (otherwise you get an error):  
  file: UploadFile,
I needed also to remove a dot in front of the model import:
```python
  from models import File
```

## Start the server

Now you can start the server in the app folder with:
```sh
$ python3 main.py
``` 
The file log.ini is not mandatory, but it is nice to have.  
If not used, you should also remove 'log_config=f"{cwd}/log.ini"' frm the start command in main.py.  

You can access the OpenAPI documentation at http://localhost:8000/docs.

## Custom Template
If you want to generate custom `*.py` files then you can give a custom template directory to fastapi-code-generator with `-t` or `--template-dir` options of the command.

fastapi-code-generator will search for [jinja2](https://jinja.palletsprojects.com/) template files in given template directory, for example `some_jinja_templates/list_pets.py`.

```bash
fastapi-code-generator --template-dir some_jinja_templates --output app --input api.yaml
```

These files will be rendered and written to the output directory. Also, the generated file names will be created with the template name and extension of `*.py`, for example `app/list_pets.py` will be a separate file generated from the jinja template alongside the default `app/main.py`

### Variables
You can use the following variables in the jinja2 templates

- `imports`  all imports statements
- `info`  all info statements
- `operations` `operations` is list of `operation`
  - `operation.type` HTTP METHOD
  - `operation.path` Path
  - `operation.snake_case_path` Snake-cased Path
  - `operation.response` response object
  - `operation.function_name` function name is created `operationId` or `METHOD` + `Path` 
  - `operation.snake_case_arguments` Snake-cased function arguments
  - `operation.security` [Security](https://swagger.io/docs/specification/authentication/)
  - `operation.summary` a summary
  - `operation.tags` [Tags](https://swagger.io/docs/specification/grouping-operations-with-tags/)

### default template 
`main.jinja2`
```jinja2
from __future__ import annotations

from fastapi import FastAPI

{{imports}}

app = FastAPI(
    {% if info %}
    {% for key,value in info.items() %}
    {{ key }} = "{{ value }}",
    {% endfor %}
    {% endif %}
    )


{% for operation in operations %}
@app.{{operation.type}}('{{operation.snake_case_path}}', response_model={{operation.response}})
def {{operation.function_name}}({{operation.snake_case_arguments}}) -> {{operation.response}}:
    {%- if operation.summary %}
    """
    {{ operation.summary }}
    """
    {%- endif %}
    pass
{% endfor %}

```

## Custom Visitors

Custom visitors allow you to pass custom variables to your custom templates.

E.g.

### custom template
`custom-template.jinja2`
```jinja2
#{ % custom_header %}
from __future__ import annotations

from fastapi import FastAPI

...
```

### custom visitor
`custom-visitor.py`
```python
from typing import Dict, Optional

from fastapi_code_generator.parser import OpenAPIParser
from fastapi_code_generator.visitor import Visitor


def custom_visitor(parser: OpenAPIParser, model_path: Path) -> Dict[str, object]:
    return {'custom_header': 'My header'}


visit: Visitor = custom_visitor
```

## PyPi 

[https://pypi.org/project/fastapi-code-generator](https://pypi.org/project/fastapi-code-generator)

## License

fastapi-code-generator is released under the MIT License. http://www.opensource.org/licenses/mit-license

